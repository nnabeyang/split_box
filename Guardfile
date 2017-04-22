guard :minitest do
  watch(%r{^(.*)\.rb$}) { |m| "test/test_#{m[1]}.rb" }
  watch(%r{^test/test_(.*)\.rb$}) { |m| "test/test_#{m[1]}.rb" }
end
