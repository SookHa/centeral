irb
require "lib/dvdcore.rb"

# for now this is hard coded for 10 node networks
def thirty_percent_perturbation(network)
  all_genes_affected_by_perts = 0
  for j in 10..14 do  
    # for each perturbation sum up in how many networks it appears
    genes_affected_by_pert_j = 0
    for i in 0..9 do  
      genes_affected_by_pert_j += network[i][j]
      all_genes_affected_by_perts += network[i][j]
    end
    # each perturbation must affect 2-4 genes
    unless (2 <= genes_affected_by_pert_j && genes_affected_by_pert_j <=4)
      return false
    end
    # 5 perturbations affecting ~1/3 of the genes => we expect 50/3 = 16.6
    in_range = 13<all_genes_affected_by_perts && all_genes_affected_by_perts<19
    return  
  end
end


def add_componentwise(sum, output) 
  for i in 0..output.length-1 do 
    for j in 0..output[i].length-1 do
      if ( sum[i].nil? )
        sum[i] = Array.new
      end
      if ( sum[i][j].nil? )
        sum[i][j] = output[i][j]
      else
        sum[i][j] = output[i][j] + sum[i][j]
      end
    end
  end
  sum
end

#split output into functionfiles
def split_data_into_files(datafile)
  datafiles = []
  output = NIL
  File.open(datafile) do |file| 
      counter = 1 
      something_was_written = FALSE
      while line = file.gets 
          # parse lines and break into different files at #
          if( line.match( /^\s*Model/ ) )
              if (something_was_written && output) 
                  output.close
                  output = NIL
              end
              something_was_written = FALSE
          else 
              if (!something_was_written) 
                  outputfile_name = datafile.gsub(/\.txt/, "-" + counter.to_s + ".functionfile.txt")
                  counter +=1
                  output = File.open(outputfile_name, "w") 
                  datafiles.push(outputfile_name)
              end
              # check if line matches @n_nodes digits
              if (line.match( /^\s*f\d*/) )
                  output.puts line
                  something_was_written = TRUE
              end
          end
      end 
      file.close
      if (output) 
          output.close
      end
  end
  datafiles
end


require "lib/dvdcore.rb"

for k in 1..5 do 
  sum = Array.new()
  output = Array.new()
  functionfiles = split_data_into_files("/Users/fhinkel/Sites/github/htdocs/public/files/output-#{k}.txt")
  functionfiles.each do |functionfile|
    file_prefix = functionfile.sub(/\.functionfile\.txt/, "")
    file_prefix.sub!(/\/Users\/fhinkel\/Sites\/github\/htdocs\//,"")
    puts file_prefix
    dvd = DVDCore.new(file_prefix, 110, 2)
    dvd.run
    output = dvd.observe_dependencies_in_array
     #  Only count the networks with the perturbations affecting the correct
     #  number of genes
    if thirty_percent_perturbations(output) 
      add_componentwise(sum, output)
    end

  end
  outfile = File.new("/Users/fhinkel/Sites/github/htdocs/public/files/output-#{k}-edges.txt", "w")
    for i in 0..sum.length-1 do 
      for j in 0..sum[i].length-1 do
        outfile.print sum[i][j] * 100 / 130
        outfile.print "\t"
      end
      outfile.puts ""
    end
  outfile.close
end



quit


