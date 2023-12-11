for file in /work/magnusdo/evoniche/minmedia/*.csv; do
    cat "$file" | cut -d, -f1 >> /work/magnusdo/evoniche/minmedia.components.csv
	sort /work/magnusdo/evoniche/minmedia.components.csv | uniq > /work/magnusdo/evoniche/minmedia.components.uniq.csv
	mv -f /work/magnusdo/evoniche/minmedia.components.uniq.csv /work/magnusdo/evoniche/minmedia.components.csv
done

