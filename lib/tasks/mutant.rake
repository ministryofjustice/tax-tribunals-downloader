task :mutant do
  vars = 'NOCOVERAGE=true'
  flags = '--include lib --require tax_tribunal --use rspec --fail-fast'
  raise 'mutation testing failed' unless system("#{vars} mutant #{flags} TaxTribunal*")
end

task(:default).prerequisites # << task(:mutant)
