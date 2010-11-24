Gem::Specification.new do |s|
  s.name = 'sortable_list'
  s.version = '0.0.3'
  s.homepage = 'http://wiki.github.com/eric1234/sortable_list/'
  s.author = 'Eric Anderson'
  s.email = 'eric@pixelwareinc.com'
  s.add_dependency 'rails', '> 3'
  s.files = Dir['lib/**/*.rb']
  s.has_rdoc = true
  s.extra_rdoc_files << 'README'
  s.rdoc_options << '--main' << 'README'
  s.summary = 'A simple helper to make sortable tables'
  s.description = <<-DESCRIPTION
    Provides a simple helper to assist in making sortable tables.
  DESCRIPTION
end
