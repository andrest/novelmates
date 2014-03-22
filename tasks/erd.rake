task :erd do
  require "rails_erd/diagram/graphviz"
  RailsERD::Diagram::Graphviz.create(
    filename: ('/Users/Andres/projects/Novelmates/docs/erd')
  )
end