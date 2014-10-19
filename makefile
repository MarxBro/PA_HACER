DESTINO_MANPAGE:=/usr/share/man/man1
#DESTINO=/usr/local/bin
DESTINO=/root/bin 

all: install doc

install:
	cp PA_HACER.pl $(DESTINO) 

doc:
	pod2man PA_HACER.pl > PA_HACER.1 && mv PA_HACER.1 $(DESTINO_MANPAGE)
	ln -s $(DESTINO_MANPAGE)/PA_HACER.1 $(DESTINO_MANPAGE)/T.1

clean: 
	rm -f $(which PA_HACER.pl) $(DESTINO_MANPAGE)/PA_HACER.1 
	unlink $(DESTINO_MANPAGE)/T.1 && rm -f $(DESTINO_MANPAGE)/T.1
