require "set"

text = <<-END
000000000000000000000000
000011100000000110000000
000001100100000011100000
000000111100000001111000
000000000000000000000000
000000000000000111100000
000000010000001000000000
000000111000000000000000
000000001110000000000000
000000000000000000000000
000000000000100000000000
000011100000000011000000
END

# Step 1. Convert text into an array of arrays and assign it to a variable called matrix, such that matrix[0][0] => '0'

MATRIX = text.split("\n").collect{|line| line.strip.split("")}


# Step 2. Find the number of "islands of ones" in the matrix; an island of ones is defined as one or more '1' 
# characters and connected to other '1' characters either horizontally or vertically, but not diagonally

# => N (number of islands)

# Some constants to make life liveable.
MAX_X = MATRIX[0].size - 1
MAX_Y = MATRIX.size - 1
MIN_X = MIN_Y = 0
X = 0
Y = 1

# A recursive search given a coordinate.  Makes heavy use of globals and constants, above.
# Arguments:  :coordinate: is a desired starting point on the grid.  Caller is expected to send 
#             each grid coordinate in to search the entire grid.
#             :islands: can be ignored as it's used by the recursive call to keep track of
#             where it's been.
def find_neighboring_islands(coordinate, islands = [])
  # Create a set of coordinates to return.
  island_coordinates = Set.new

  if MATRIX[coordinate[Y]][coordinate[X]] == "1"
    # A hit, stow the coordinate and continue on to check out the neighbors.
    island_coordinates << coordinate
  else
    # The end of the line for this search
    return island_coordinates
  end

  # Stow this coordinate so it's not recursed over again. No circular loops!
  islands << coordinate

  # look north
  northern_neighbor = [coordinate[X], coordinate[Y] - 1]
  # If not heading offen the grid and the potential next coordinate hasn't been visited.
  if coordinate[Y] != MIN_Y && !islands.find{|coord| coord == northern_neighbor}
    returned_coordinates = find_neighboring_islands(northern_neighbor, islands)

    if returned_coordinates.any?
      island_coordinates += returned_coordinates
    end
  end

  # look south
  southern_neighbor = [coordinate[X], coordinate[Y] + 1]
 
  if coordinate[Y] != MAX_Y && !islands.find{|coord| coord == southern_neighbor}
    returned_coordinates = find_neighboring_islands(southern_neighbor, islands)

    if returned_coordinates.any?
      island_coordinates += returned_coordinates
    end
  end

  # look east
   eastern_neighbor = [coordinate[X] + 1, coordinate[Y]]

   if coordinate[X] != MAX_X && !islands.find{|coord| coord == eastern_neighbor} 
    returned_coordinates = find_neighboring_islands(eastern_neighbor, islands)
    
    if returned_coordinates.any?
      island_coordinates += returned_coordinates
    end
  end

  # look west
  western_neighbor = [coordinate[X] - 1, coordinate[Y]]

  if coordinate[X] != MIN_X && !islands.find{|coord| coord == western_neighbor}
    returned_coordinates = find_neighboring_islands(western_neighbor, islands)
    
    if returned_coordinates.any?
      island_coordinates += returned_coordinates
    end
  end
  
  # All done, send the results back home.
  return island_coordinates
end


island_bucket = Set.new

puts "Finding islands in the matrix [#{MATRIX[0].size}, #{MATRIX.size}]"

# A simple loop/loop to send all the coordinates to the island-finder
# and collect the results from each call/coordinate.
(0..MAX_X).each do |x|
  (0..MAX_Y).each do |y|
    island_bucket << find_neighboring_islands([x, y])
  end
end

# Throw away empties
island_bucket.reject!{|island| island.empty?}

# Print out the found islands
island_bucket.each_with_index do |island, index|
  puts "#{index + 1}: #{island.inspect}"
end

puts "\nFound #{island_bucket.size} islands in the matrix.\n"

# Print the original matrix (text).
puts "\nOriginal Matrix"
puts text

# Update the matrix by claiming all of the islands.
island_bucket.each_with_index do |island, index|
  island.each do |coordinate|
    # The matrix is acutally off by 90 degrees, so reverse X and Y to 
    # account for this.
    MATRIX[coordinate[Y]][coordinate[X]] = (index + 1).to_s
  end
end

# Show off the hard work!
puts "\n Claimed islands"
rows =  MATRIX.collect{|row| row.collect{|cell| cell.to_s}.join}
puts rows

