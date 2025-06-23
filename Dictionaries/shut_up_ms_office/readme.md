## Shut Up MS Office
### IT and Cybersecurity Terms

Just a worldlist I threw together really quickly. **Import it as a custom dictionary, see less red from spellcheck!**

Ideally I'll put together some scraping in Python with BeautifulSoup, some day. For now I did the quick 'n dirty route:

```
shane@Shanes-Laptop tooldict % cat cyberguideme:Tools:\ Cyber\ Security\ Tools.html|  grep "<li><a hre" | grep -oE ">[A-Za-z0-9_-]+<" | tr -d '><' >> source1.txt
shane@Shanes-Laptop tooldict % cat Kali\ Tools\ \|\ Kali\ Linux\ Tools.html | grep "<a href=https://www.kali.org/tools" | grep -Eo "[A-Za-z0-9_-]+</a>" | sed 's~</a>~~' >> source2.txt
shane@Shanes-Laptop tooldict % cat enaqx:awesome-pentest:\ A\ collection\ of\ awesome\ penetration\ testing\ resources,\ tools\ and\ other\ shiny\ .html | grep "<a href" | grep -Eo ">[A-Za-z0-9_-]+<" | tr -d "<>" >> source3.txt
shane@Shanes-Laptop tooldict % cat sindresorhus:awesome:\ 😎\ Awesome\ lists\ about\ all\ kinds\ of\ interesting\ topics.html | grep "<li><a href" | grep -Eo ">[A-Za-z0-9_-]+<" | tr -d "<>" >> source4.txt
shane@Shanes-Laptop tooldict % cat awesome-foss:awesome-sysadmin:\ A\ curated\ list\ of\ amazingly\ awesome\ open-source\ sysadmin\ resources..html | grep "<li><a href" | grep -Eo ">[A-Za-z0-9_-]+<" | tr -d "<>" >> source5.txt
shane@Shanes-Laptop tooldict % cat trimstray:the-book-of-secret-knowledge:\ A\ collection\ of\ inspiring\ lists,\ manuals,\ cheatsheets,\ blogs.html | grep "<a href=.*><b>" | grep -oE ">[A-Za-z0-9_]+<" | tr -d "><" >> source6.txt
shane@Shanes-Laptop tooldict % cat vinta:awesome-python:\ An\ opinionated\ list\ of\ awesome\ Python\ frameworks,\ libraries,\ software\ and\ reso.html | grep "<li><a href" | grep -oE ">[A-Aa-z0-9_-]+<" | tr -d "><" | grep -v "^awesome" >> source7.txt
shane@Shanes-Laptop tooldict % cat List\ of\ computing\ and\ IT\ abbreviations\ -\ Wikipedia.html| grep "<li><a href" | grep -oE ">[A-Za-z0-9_-]+<" | tr -d "><" >> source8.txt
shane@Shanes-Laptop tooldict % cat List\ of\ computing\ and\ IT\ abbreviations\ -\ Wikipedia.html| grep "<li><a href" | grep -oE "title=\"[A-Za-z0-9_-]+\"" | sed -e s/^title=\"// -e s/\"$//

shane@Shanes-Laptop tooldict % wc -l *.txt
     302 source1.txt
     465 source2.txt
     411 source3.txt
     406 source4.txt
     575 source5.txt
     409 source6.txt
     494 source7.txt
    1753 source8.txt
    4815 total

shane@Shanes-Laptop tooldict % cat source*.txt | sort -d -u >> sorted_deduplicated.txt

shane@Shanes-Laptop tooldict % wc -l sorted_deduplicated.txt

shane@Shanes-Laptop tooldict % cat Dictionary.dic | iconv -f ASCII -t UTF-16LE | unix2dos -u -ul >> Dict161.dic
```
