require 'rake'

task :default => [:features, :spec]

task :code_generation => ['lib/parser/intermediate.rb']

file 'lib/parser/intermediate.rb' => 'lib/parser/intermediate.treetop' do
	desc "Generate parser for intermediate language from treetop grammar"
	sh "tt -f lib/parser/intermediate.treetop -o lib/parser/intermediate.rb"
end

task :spec => [:code_generation] do
	sh "rspec -f d"
end

task :features => [:code_generation] do
	sh "cucumber -f pretty -s"
end
