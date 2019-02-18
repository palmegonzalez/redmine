module Redmine
  module Export
    module PDF
      module ProjectsPdfHelper
        include IssuesHelper

      	def projects_to_pdf(projects, query)
      	  pdf = ITCPDF.new(current_language, "L")
          pdf.set_title("Proyectos")
          pdf.alias_nb_pages
          pdf.footer_date = format_date(User.current.today)
          pdf.add_page("L")

          # Landscape A4 = 210 x 297 mm
          page_height   = pdf.get_page_height # 210
          page_width    = pdf.get_page_width  # 297
          left_margin   = pdf.get_original_margins['left'] # 10
          right_margin  = pdf.get_original_margins['right'] # 10
          bottom_margin = pdf.get_footer_margin
          row_height    = 4

          pdf.set_auto_page_break(true, bottom_margin*2)
          # title
          pdf.SetFontStyle('B',15)
          pdf.RDMCell(190, 8, 'Proyectos Plan Estratégico UNLP')
          pdf.ln
          pdf.ln


          projects.each do |project|
            pdf.SetFontStyle('B',11)
            pdf.RDMCell(190, 8, project.name)
            pdf.ln
            pdf.ln

            if project.issues.empty?
              pdf.SetFontStyle('',9)
              pdf.RDMCell(190, 8, 'El proyecto no tiene peticiones cargadas')
              pdf.ln
              pdf.ln
            else
              # column widths
              table_width = page_width - right_margin - left_margin
              col_width = []
              unless query.inline_columns.empty?
                col_width = calc_col_width(project.issues, query, table_width, pdf)
                table_width = col_width.inject(0, :+)
              end

              # use full width if the description or last_notes are displayed
              if table_width > 0 && (query.has_column?(:description) || query.has_column?(:last_notes))
                col_width = col_width.map {|w| w * (page_width - right_margin - left_margin) / table_width}
                table_width = col_width.inject(0, :+)
              end

              base_y     = pdf.get_y
              max_height = get_issues_to_pdf_write_cells(pdf, query.inline_columns, col_width)
              space_left = page_height - base_y - (bottom_margin * 2)

              if max_height > space_left
                pdf.add_page("L")
                render_table_header(pdf, query, col_width, row_height, table_width)
                base_y = pdf.get_y
              else
                render_table_header(pdf, query, col_width, row_height, table_width)
              end

              issue_list(project.issues) do |issue, level|

                # fetch row values
                col_values = fetch_row_values(issue, query, level)

                # make new page if it doesn't fit on the current one
                base_y     = pdf.get_y
                max_height = get_issues_to_pdf_write_cells(pdf, col_values, col_width)
                space_left = page_height - base_y - (bottom_margin * 2)
                if max_height > space_left
                  pdf.add_page("L")
                  render_table_header(pdf, query, col_width, row_height, table_width)
                  base_y = pdf.get_y
                end

                # write the cells on page
                issues_to_pdf_write_cells(pdf, col_values, col_width, max_height)
                pdf.set_y(base_y + max_height)

                if query.has_column?(:description) && issue.description?
                  pdf.set_x(10)
                  pdf.set_auto_page_break(true, bottom_margin)
                  pdf.RDMwriteHTMLCell(0, 5, 10, '', issue.description.to_s, issue.attachments, "LRBT")
                  pdf.set_auto_page_break(false)
                end

                if query.has_column?(:last_notes) && issue.last_notes.present?
                  pdf.set_x(10)
                  pdf.set_auto_page_break(true, bottom_margin)
                  pdf.RDMwriteHTMLCell(0, 5, 10, '', issue.last_notes.to_s, [], "LRBT")
                  pdf.set_auto_page_break(false)
                end
              end
              pdf.ln

            end
          end
          pdf.output
      	end


        # calculate columns width
        def calc_col_width(issues, query, table_width, pdf)
          # calculate statistics
          #  by captions
          pdf.SetFontStyle('B',8)
          margins = pdf.get_margins
          col_padding = margins['cell']
          col_width_min = query.inline_columns.map {|v| pdf.get_string_width(v.caption) + col_padding}
          col_width_max = Array.new(col_width_min)
          col_width_avg = Array.new(col_width_min)
          col_min = pdf.get_string_width('OO') + col_padding * 2
          if table_width > col_min * col_width_avg.length
            table_width -= col_min * col_width_avg.length
          else
            col_min = pdf.get_string_width('O') + col_padding * 2
            if table_width > col_min * col_width_avg.length
              table_width -= col_min * col_width_avg.length
            else
              ratio = table_width / col_width_avg.inject(0, :+)
              return col_width = col_width_avg.map {|w| w * ratio}
            end
          end
          word_width_max = query.inline_columns.map {|c|
            n = 10
            c.caption.split.each {|w|
              x = pdf.get_string_width(w) + col_padding
              n = x if n < x
            }
            n
          }

          #  by properties of issues
          pdf.SetFontStyle('',8)
          k = 1
          issue_list(issues) {|issue, level|
            k += 1
            values = fetch_row_values(issue, query, level)
            values.each_with_index {|v,i|
              n = pdf.get_string_width(v) + col_padding * 2
              col_width_max[i] = n if col_width_max[i] < n
              col_width_min[i] = n if col_width_min[i] > n
              col_width_avg[i] += n
              v.split.each {|w|
                x = pdf.get_string_width(w) + col_padding
                word_width_max[i] = x if word_width_max[i] < x
              }
            }
          }
          col_width_avg.map! {|x| x / k}

          # calculate columns width
          ratio = table_width / col_width_avg.inject(0, :+)
          col_width = col_width_avg.map {|w| w * ratio}

          # correct max word width if too many columns
          ratio = table_width / word_width_max.inject(0, :+)
          word_width_max.map! {|v| v * ratio} if ratio < 1

          # correct and lock width of some columns
          done = 1
          col_fix = []
          col_width.each_with_index do |w,i|
            if w > col_width_max[i]
              col_width[i] = col_width_max[i]
              col_fix[i] = 1
              done = 0
            elsif w < word_width_max[i]
              col_width[i] = word_width_max[i]
              col_fix[i] = 1
              done = 0
            else
              col_fix[i] = 0
            end
          end

          # iterate while need to correct and lock coluns width
          while done == 0
            # calculate free & locked columns width
            done = 1
            ratio = table_width / col_width.inject(0, :+)

            # correct columns width
            col_width.each_with_index do |w,i|
              if col_fix[i] == 0
                col_width[i] = w * ratio

                # check if column width less then max word width
                if col_width[i] < word_width_max[i]
                  col_width[i] = word_width_max[i]
                  col_fix[i] = 1
                  done = 0
                elsif col_width[i] > col_width_max[i]
                  col_width[i] = col_width_max[i]
                  col_fix[i] = 1
                  done = 0
                end
              end
            end
          end

          ratio = table_width / col_width.inject(0, :+)
          col_width.map! {|v| v * ratio + col_min}
          col_width
        end

        def render_table_header(pdf, query, col_width, row_height, table_width)
          # headers
          pdf.SetFontStyle('B',8)
          pdf.set_fill_color(230, 230, 230)

          base_x     = pdf.get_x
          base_y     = pdf.get_y
          max_height = get_issues_to_pdf_write_cells(pdf, query.inline_columns, col_width, true)

          # write the cells on page
          issues_to_pdf_write_cells(pdf, query.inline_columns, col_width, max_height, true)
          pdf.set_xy(base_x, base_y + max_height)

          # rows
          pdf.SetFontStyle('',8)
          pdf.set_fill_color(255, 255, 255)
        end

        # returns the maximum height of MultiCells
        def get_issues_to_pdf_write_cells(pdf, col_values, col_widths, head=false)
          heights = []
          col_values.each_with_index do |column, i|
            heights << pdf.get_string_height(col_widths[i], head ? column.caption : column)
          end
          return heights.max
        end

        # Renders MultiCells and returns the maximum height used
        def issues_to_pdf_write_cells(pdf, col_values, col_widths, row_height, head=false)
          col_values.each_with_index do |column, i|
            pdf.RDMMultiCell(col_widths[i], row_height, head ? column.caption : column.strip, 1, '', 1, 0)
          end
        end



      end
    end
  end
end