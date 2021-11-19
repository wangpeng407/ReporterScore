curl  http://rest.kegg.jp/link/pathway/ko  -o pathway-KO.raw.list
sed 's/ko://g;s/path://g' pathway-KO.raw.list | grep map > pathway-KO.list

curl http://rest.kegg.jp/link/module/ko -o module-KO.raw.list
sed 's/ko://g;s/md://g' module-KO.raw.list > module-KO.list

curl http://rest.kegg.jp/list/module | sed 's/^md://g' > module.desc.list

curl http://rest.kegg.jp/list/pathway | sed 's/^path://g' > pathway.desc.list
perl handle.pl pathway-KO.list pathway.desc.list > path_stat_KO.xls
perl handle.pl module-KO.list module.desc.list > module_stat_KO.xls

mv pathway-KO.raw.list pathway-KO.list module-KO.raw.list module-KO.list module.desc.list pathway.desc.list old

