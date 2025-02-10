echo "FASTA File Statistics:"
echo "----------------------"

if [ "$#" -ne "1" ]; then
    echo "Bad number of parameter. Please input one file.fna"
    exit
fi

sequences=$(awk '!/^>/{print}' "$1")
num_seq=$(grep -c '^>' $1)
total_length=$(awk '/^>/ {next} {total += length($0)} END {print total}' "$1")
length=$(awk '/^>/ {next} {print length}' "$1") 
max_length=$(echo "$length" | sort -nr | head -n1)
min_length=$(echo "$length" | sort -n | head -n1)
#avg_length=$((total_length / num_seq))
avg_length=$(awk "BEGIN {print $total_length / $num_seq}")
gc_count= $(echo "$sequences" | grep -o '[GCgc]' | wc -l)
#gc_content= echo "$gc_count * 100 / $total_length" | bc -l
gc_content=$(awk "BEGIN {print ($gc_count * 100) / $total_length}")

echo "Number of sequences: $num_seq"
echo "Total length of sequences: $total_length"
echo "Length of the longest sequence: $max_length"
echo "Length of the shortest sequence: $min_length"
echo "Average sequence length: $avg_length"
echo "GC Content (%): $gc_count"

