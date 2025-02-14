# remove COMBINED-DATA directory if it might exist
rm -rf COMBINED-DATA

# create a new COMBINED-DATA directory (known for sure no previous ones)
if [ ! -d "COMBINED-DATA" ]; then
    mkdir "COMBINED-DATA"
fi

# loop through all directories that have FASTA files
for fasta in $(ls -d RAW-DATA/DNA*); do
    # extract the culture name
    culture_name=$(basename $fasta)

    # assign the new name for a given culture from sample-translation.txt
    new_culture_name=$(grep $culture_name RAW-DATA/sample-translation.txt | awk '{print $2}')

    # assign new variables for the downstream process of numbering final FASTA files having either a BIN or a MAG
    MAG_count=1
    BIN_count=1

    # copy files that contain completion estimates and taxonomy into the new directory COMBINED-DATA as XXX-CHECKM.txt and XXX-GTDB-TAX.txt
    cp $fasta/checkm.txt COMBINED-DATA/$new_culture_name-CHECKM.txt
    cp $fasta/gtdb.gtdbtk.tax COMBINED-DATA/$new_culture_name-GTDB-TAX.txt

    # loop through each FASTA file in the bins/ directory
    for fasta_file in $fasta/bins/*.fasta; do
        # assign the bin name, removing the "fasta" in it by using .fasta
        bin_name=$(basename $fasta_file .fasta)

        # search and print the completion and contamination estimated percentages for the bin (13th & 14th columns from checkm.txt)
        completion=$(grep "$bin_name" $fasta/checkm.txt | awk '{print $13}')
        contamination=$(grep "$bin_name" $fasta/checkm.txt | awk '{print $14}')

    # set the "new name" using UNBINNED, BIN, or MAG
        #if the bin is unbinned name it "UNBINNED" 
        if [[ $bin_name == bin-unbinned ]]; then
            new_name="${new_culture_name}_UNBINNED.fa"
        # if completion is ≥50% and contamination is <5%, it's a MAG.
        elif (( $(echo "$completion >= 50" | bc -l) && $(echo "$contamination < 5" | bc -l) )); then
            new_name=$(printf "${new_culture_name}_MAG_%03d.fa" $MAG_count)
            MAG_count=$(("$MAG_count + 1"))
        #otherwise, it's a BIN
        else
            new_name=$(printf "${new_culture_name}_BIN_%03d.fa" $BIN_count)
            BIN_count=$(($BIN_count + 1))
        fi
        echo "Working. Please wait a second."

        #update the names, replace the old bin name with the new bin name
        sed -i "s/ms.*${bin_name}/$(basename "$new_name" .fa)/g" "COMBINED-DATA/${new_culture_name}-CHECKM.txt"
        sed -i "s/ms.*${bin_name}/$(basename "$new_name" .fa)/g" "COMBINED-DATA/${new_culture_name}-GTDB-TAX.txt"

        # copy to the new file
        cp $fasta_file COMBINED-DATA/$new_name
    done
done