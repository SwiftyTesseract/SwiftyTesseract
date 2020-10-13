swift build

expected='1234567890'
actual=$(swift run recognize-text Tests/recognize-textTests/image_sample.jpg)

if [ "$actual" = "$expected" ]; then
  echo "Test Passed"
  exit 0
else
  echo "Test Failed"
  exit 1
fi