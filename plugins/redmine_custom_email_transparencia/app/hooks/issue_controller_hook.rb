module CustomEmailTransparencia
  class IssueControllerHooks < Redmine::Hook::Listener

    def controller_issues_new_after_save(context = {})
      params, issue, time_entry, journal = context.values_at(:params, :issue, :time_entry, :journal)

      requester_email = issue.custom_field_values.find { |i| i.custom_field.name == "Email"}

      if requester_email.present?
        RequesterMailer.requester_issue_add(issue, requester_email).deliver
      end
    end

    def controller_issues_edit_after_save(context = {})
      params, issue, time_entry, journal = context.values_at(:params, :issue, :time_entry, :journal)

      requester_email = issue.custom_field_values.find { |i| i.custom_field.name == "Email"}
      status_retrieval = IssueStatus.find_by name: "En subsanación"
      status_inadmissible = IssueStatus.find_by name: "No Admisible"

      if requester_email.present?
        case issue.status
          when status_retrieval
            RequesterMailer.requester_issue_edit(issue, requester_email).deliver
          when status_inadmissible
            RequesterMailer.requester_issue_finish(issue, requester_email).deliver
        end
      end

    end
  end
end