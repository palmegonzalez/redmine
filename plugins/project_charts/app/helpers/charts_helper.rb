module ChartsHelper
  def self.dataForBubble(project)
    {
      name: 'Grado de Avance',
      title: 'Grado de Avance',
      subtitle: project.name,
      xAxis_title: 'Última Actualización',
      xAxis_label: '{value}',
      yAxis_title: 'Completitud de la tarea',
      yAxis_label: '{value}%',
      tooltip_x: 'Última Actualización',
      tooltip_y: 'Completitud',
      tooltip_z: 'Grado de Impacto',
      series: self.build_series(project)
    }
  end

  def self.issues_for(project)
    project.issues + project.children.map { |sub| self.issues_for(sub) }.flatten
  end

  #FIX: Remove this method. This is only for build a prototipe.
  def self.children_names(project)
    project.children.map { |child| {name: child.name, color: "%06x" % (rand * 0xffffff)} }
  end

  def self.build_series(project)
    data = self.children_names(project)

    serie1 = data.map do |each|
      { x: rand(DateTime.new(2018,7,1).to_i * 1000..DateTime.new(2018,7,31).to_i * 1000 ),
        y: rand(0..100),
        z: rand(0..10),
        name: each[:name].split('[').first ,
        color: '#' + each[:color],
        complete_name: each[:name]
      }
    end

    serie2 = data.map do |each|
      { x: rand(DateTime.new(2018,8,1).to_i * 1000..DateTime.new(2018,8,31).to_i * 1000 ),
        y: rand(0..100),
        z: rand(0..10),
        name: each[:name].split('[').first ,
        color: '#' + each[:color],
        complete_name: each[:name]
      }
    end

    serie3 = data.map do |each|
      { x: rand(DateTime.new(2018,9,1).to_i * 1000..DateTime.new(2018,9,30).to_i * 1000 ),
        y: rand(0..100),
        z: rand(0..10),
        name: each[:name].split('[').first ,
        color: '#' + each[:color],
        complete_name: each[:name]
      }
    end



    [serie1, serie2, serie3].flatten.to_json.html_safe
  end
end