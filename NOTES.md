English version

Part 0: What I got out of it

Over the last few days I put real effort into figuring out how Git and GitHub actually fit together on my computer. I didn’t just read about it. After every step I went into the files to see what had changed. Here’s what I found. HEAD points to the branch I’m currently on. If I cat that branch file, I get a commit hash. Running git cat-file -p on that hash shows the tree and the parent hash, so every new commit points back to the one before it, its parent. origin is just a name for the address of the GitHub repo. git status compares my local commits with where origin/main was the last time I talked to GitHub, and that’s not live. .git/config stores the remote’s name, its URL and the tracking info. Inside .git/refs/remotes/origin there are two files, HEAD and main, and HEAD just points to main. If I cat that main I get a hash, open it with cat-file and I see tree and parent again. The difference between the two mains: the one under origin remembers the last commit I saw on GitHub (not live), and the local one is my own latest commit. A branch file only holds one hash, the newest commit, but since every commit links to its parent, the older commits never disappear. Branches are just pointers.

I learned where branches and commits are stored.
I learned that a commit stores its parent inside itself.
I learned that origin is just a name for the repo’s address.
I learned that git status checks my changes against the last commit and lists what changed, so I can see what’s about to get committed and pushed.
I learned the difference between origin/main and my local main.
I learned how the check between my computer and GitHub works, and that it’s not live.
I learned that HEAD holds the name of the branch I’m working on, and the branch holds the latest commit.
I learned that the same content always gets the same hash.
I learned that Git can’t track empty folders, and that putting a .gitkeep file inside is the usual trick to get around that.
I learned that both HTTPS and SSH are encrypted. The difference is how you prove who you are: with SSH it’s a private key that never leaves my computer, with HTTPS it’s a token. Public key is the lock, private key is the key.
I learned how to create an SSH key in the terminal, add it to GitHub and push to my repo with it.
I learned that you can’t create a branch before the first commit.


Orijinal Versiyon:

Bölüm 0'ın Katkıları:

Son birkaç gündür gerçekten yoğun emeğimi vererek Git'in ve GitHub'ın bilgisayarda nasıl eşleştiklerini, sadece anlamakla kalmayıp bunları terminal üzerinden her işlem dosyalar içerisinden neleri değiştiriyor merakıyla kontrol ettim. Bunların listesi: HEAD üzerinde çalıştığımız branchi gösterir ve referansını da gösterir. Bu referanstaki branch isminin içeriğine cat ile baktığımızda karşımıza hash code'u çıkar. Bu hash code'unu git cat-file -p HASH yaptığımız zaman içerisinde tree ve parent hash code'larını buluruz, buradan şu sonucu çıkarırız, yeni commit eski commit'e yani parent'ına işaret eder, bunu hash code'unu cat-file ile açarak bulabiliriz. Origin'in GitHub'daki dosyaları pointlediğini gördüm. Localdeki dosyalar ile GitHub'daki dosyaların eşit olup olmadığını "git status" belirliyor, ama bu da canlı bir sistem değil. Ayriyeten .git/config ile remote'un adını, URL'sini ve takip ilişkisini tutar. .git/refs/remotes/origin içerisinde HEAD ve main diye iki ayrı dosya var, HEAD dosyası zaten yanındaki main'i gösteriyor. cat main dediğimiz zaman hash code'una ulaşırız ve bunu cat-file ile açtığımız zaman yine tree ve parent değerlerine ulaşırız, yani origin'in bir önceki commit'ine ulaşırız. İlk main ile bu main arasındaki fark, bu main GitHub'daki en sonki dosya durumunu tutuyor canlı değil, öbürü de localdeki commitleri yani dosya değişimlerini gösterir. HEAD üzerinde çalıştığın branchin adını söyler bu önemli, HEAD referans ettiği main'ler en sonki commit'in hash code'unu gösterir ama sadece 1 tane gösterir parent'a erişilebildiği için aslında önceki commitler hiçbir zaman kaybolmuyor branchler pointerlık yapıyorlar.

Branch'lerin ve commit'lerin kayıtlarının nerede tutulduklarını öğrendim.
Commit'lerin parent'larını kendi içerisinde kaydettiklerini öğrendim.
Origin'in repository'nin adresini pointlediğini öğrendim
Git status'un en sonki commiti baz alarak, yapılan değişiklikleri kontrol edip, değişen dosyaları veya klasörleri listeleyen, böylece pushlanacak olan dosyaların ayırt edilmesini sağlar.
Origin'in main'ini ve local main'in içerik farkını öğrendim.
Local bilgisayar ile GitHub arasındaki dosya eşlik kontrol sisteminin nasıl çalıştığını öğrendim.
HEAD işlem yaptığımız branch'in adını, main'lerin de en son yapılan commit'i kaydettiğini öğrendim.
Aynı içeriğin aynı hash code'a tekabül ettiğini öğrendim. 
Boş dosya'nın Git'de push edilemeyeceğini, bunun için .gitkeep kullanılması gerektiğini öğrendim.
SSH'ın şifreli bağlantı ile anahtar ve kilit mantığıyla çalıştığını öğrendim. Kilit publictir fakat anahtar private'dır. HTTPS şifreli girişi sağlar, SSH ise özel private anahtar ile girişi sağlar. 
SSH keyi terminalden oluşturup GitHub'a kaydetmeyi ve repository'me güvenli bir şekilde pushlamayı öğrendim SSH ile.
Commit olmadan branch açılmayacağını öğrendim.


Proje için şu ana kadar elle tutulur neler yaptım:

Terminalde ssh ve git'i kurdum,
Git için kullanacağım maili ve ismi ayarladım,
GitHub'da proje için attack-watch adında repo oluşturdum,
Bilgisayarımı Git ile repoya bağladım,
SSH ile güvenli bağlantı kurdum,
Dosya yapısını projenin isteklerine göre düzenledim,
.gitignore oluşturarak private dosyaların yanlışlıkla pushlanmasını önledim,


Bir sonraki sefer başına oturduğumda Azure'da kayıtlı kart ve kalan kredi bilgisine bakacağım,
Sorun yoksa, subscription, resource group ve region kavramlarını öğreneceğim, 
Budget alert kurmayı öğreneceğim, 
Cost analysis ekranı okumayı öğreneceğim, 
5 birimlik bütçe oluşturacağım, 
Devamı görevler pdfinde



Part 1: What I got out of it
I learned the importance of budget alerts, and I learned how to set up budget alerts through Azure platform
I learned management area, subscription, resource group and resources hierarchy on Microsoft Azure
I learned managing all the resources on 1 resource group is the best way to organize the project, also to delete without any remaining files and to check credits that it spend on that specific resource group.
I turn on the budget alarm at %50, %80 and %100, so system will send me an email when I exceed these percentage limits everytime.

Part 2: What I got out of it
I created my first Linux Virtual Machine on Azure,
I learned free services' strict rules and applied to my project, 
I solved the free services' region issue and learned to select the correct one,
I arranged disk and network settings,
I deployed the virtual machine, it is ready to use,
I learned NSG rules and prepared the network rules to get attacked by hack bots.

