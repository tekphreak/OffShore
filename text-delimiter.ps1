$INPUT_FILE = "input.txt"
$OUTPUT_FILE = "output.txt"
$DELIMS = ",."

# Read the input file, split each line by delimiters, and add "STRING " to the beginning of each non-empty line.
Get-Content $INPUT_FILE | ForEach-Object {
  $lines = ($_ -split "[$($DELIMS)]") | ForEach-Object { 
    if ($_ -match '\S') { "STRING $_" } else { $null }
  }
  $content = $lines -join "`n"
  if ($content -match '\S') { Add-Content -Path $OUTPUT_FILE -Value $content }
}
