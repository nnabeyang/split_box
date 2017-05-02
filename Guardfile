guard :minitest do
  watch(%r{^lib/split_box/(.*)\.rb$}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^test/(.*)_test\.rb$}) { |m| "test/#{m[1]}_test.rb" }
end
