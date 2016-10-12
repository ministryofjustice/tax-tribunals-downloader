task :mutant do
  vars = 'NOCOVERAGE=true'
  flags = '--include lib --use rspec --fail-fast'
  unless system("#{vars} mutant #{flags} TaxTribunal*")
    raise 'mutation testing failed'
  end
end

task(:default).prerequisites << task(:mutant)
