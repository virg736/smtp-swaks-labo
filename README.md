# Test SMTP pédagogique avec **swaks** (guide & labo)

**Niveau :** pentester / ingénierie sécurité (pédagogique, contrôlé)

⚠️ **Usage pédagogique uniquement** - Tous les tests décrits ici sont réalisés **en local** dans une VM Parrot OS ou dans un laboratoire isolé.
Avant toute action sur des systèmes réels, obtenir une **autorisation écrite** (Rules of Engagement).

---

## Résumé

Ce projet montre comment **créer un serveur SMTP local**, **tester** l’envoi d’e-mails avec `swaks`, **observer** le dialogue SMTP côté client/serveur et **expliquer** les protections e-mail critiques : **SPF, DKIM, DMARC, TLS**.

Objectifs pédagogiques :
- Comprendre le dialogue SMTP (EHLO/HELO, MAIL FROM, RCPT TO, DATA).
- Montrer pourquoi SMTP par défaut permet l’usurpation d’expéditeur (spoofing).
- Vérifier et interpréter les protections de domaine (SPF/DKIM/DMARC) et le transport sécurisé (STARTTLS/TLS).
- Produire des artefacts et un petit rapport (logs, traces) exploitables en audit pédagogique.

---

## Pourquoi faire ce labo ?
- **Compréhension technique :** voir réellement la session SMTP et comment les messages transitent.
- **Détection & défense :** apprendre où regarder dans les logs et quelles protections appliquer.
- **Preuve pour recruteurs :** artefacts textuels (sorties swaks, logs) démontrent tes compétences pratiques.

---

## Contenu du dépôt (extrait)
- `README.md` - introduction (ce fichier).
- `docs/demo_smtp_swaks.md` - guide pas-à-pas (installation, création serveur local, tests).
- `docs/protections_email.md` - explication SPF/DKIM/DMARC/TLS et pourquoi protéger.
- `scripts/run_demo.sh` - script safe (local only) : démarre serveur local, lance swaks, sauvegarde traces.
- `artifacts/` - sorties de tests (texte).
- `SAFE_NOTICE.md` / `ROE_MINI.md` - notices d’usage pédagogique.

---

## Règles d'or (lecture obligatoire)
- N’exécute jamais ces scripts sur des hôtes tiers ou en production.
- Utilise `example.com` dans la documentation publique si tu fais des captures.
- Conserve les preuves dans `artifacts/` et anonymise si tu publies.

---

## Prochaines étapes (rapide)
1. Suivre `docs/demo_smtp_swaks.md` pour installer et lancer la démo en local.
2. Sauvegarder les artefacts générés dans `artifacts/`.
3. Compléter `docs/protections_email.md` dans le repo avec conclusions et recommandations.


---
# Demo SMTP — Swaks + aiosmtpd (guide pas à pas)

> Tout se fait **en local** sur une VM Parrot OS ou dans un laboratoire isolé. N’exécutez jamais ces procédures sur des systèmes tiers sans autorisation écrite.

## Objectif
Montrer comment :
- créer un serveur SMTP local (aiosmtpd) pour capter des messages de test ;
- envoyer des e-mails de test avec `swaks` ;
- observer et interpréter le dialogue SMTP (client ↔ serveur) ;
- sauvegarder des artefacts (traces) exploitables pour un rapport pédagogique.

---

## Pré-requis (VM Parrot OS / Debian-like)
- Système à jour :

  sudo apt update && sudo apt upgrade -y

	•	Installer outils de base :

sudo apt install -y swaks dnsutils openssl git

	Installer pipx puis aiosmtpd (méthode recommandée) :

sudo apt install -y pipx
pipx ensurepath
# relancer le shell si nécessaire : source ~/.bashrc
pipx install aiosmtpd

Remarque : si pipx n’est pas souhaité, vous pouvez utiliser un environnement virtuel Python :

python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install aiosmtpd

Créez les dossiers :

mkdir -p ~/projet-smtp-swaks/{docs,scripts,artifacts}
cd ~/projet-smtp-swaks

1) Démarrer le serveur SMTP local (Terminal A)

Lancez aiosmtpd pour écouter sur l’interface locale (port 1025) :

aiosmtpd -n -l 127.0.0.1:1025

•	-n : ne pas daemoniser (le serveur reste au premier plan et affiche les messages reçus).
•	Laissez ce terminal ouvert : il affichera les messages au format brut (en-têtes + corps).

---

2) Envoyer un e-mail de test avec Swaks (Terminal B)

Dans un autre terminal, exécutez :

cd ~/projet-smtp-swaks
swaks --to test@example.com \
      --from demo@lab.local \
      --server 127.0.0.1 --port 1025 \
      --header "Subject: Test SMTP local" \
      --body "Ceci est un test local. Date: $(date -u)" \
      --timeout 15 \
  | tee artifacts/test_local_aiosmtpd_$(date +%Y%m%d_%H%M%S).txt

Vous obtiendrez :
	•	la trace complète de la transaction SMTP dans la sortie standard (affichée par swaks);
	•	un fichier texte horodaté dans artifacts/ contenant la sortie (utile pour le rapport).

---

3) Interpréter le dialogue SMTP (ce qu’il faut vérifier)

Lors d’une transaction réussie, observez les étapes suivantes :
	•	220 : salutation du serveur (prêt)
	•	EHLO / HELO : présentation du client (capabilities)
	•	MAIL FROM: : adresse déclarée de l’expéditeur (champ déclaratif)
	•	RCPT TO: : destinataire déclaré
	•	DATA → 354 : serveur attend le corps du message
	•	. → 250 OK : message accepté
	•	QUIT → 221 : fin de session

Remarque pédagogique : SMTP de base n’authentifie pas le champ MAIL FROM. C’est pourquoi SPF/DKIM/DMARC et l’authentification sont nécessaires côté destinataire.

---

4) Sauvegarder et vérifier les artefacts

Lister les artefacts :

ls -lh artifacts/

Afficher le contenu d’un artefact :

less artifacts/test_local_aiosmtpd_*.txt


Conservez ces fichiers dans le dépôt (ou hors dépôt si sensibles) pour preuve et reporting. Anonymisez avant publication.

---

5) Test TLS / STARTTLS (conceptuel)

Si vous souhaitez observer la négociation TLS avec un serveur externe (ex. smtp.gmail.com), utilisez :

swaks --to test@example.com --from demo@lab.local \
      --server smtp.gmail.com --port 587 --starttls --timeout 20 \
  | tee artifacts/test_starttls_$(date +%Y%m%d_%H%M%S).txt

Attention : de nombreux fournisseurs exigent une authentification pour la remise ; la connexion peut aussi être bloquée par la NAT/FAI. Ce test sert principalement à vérifier la présence et la négociation TLS.

---

6) Vérification DNS (lecture seule) - SPF / DKIM / DMARC

Exemples avec dig (remplacez example.com par le domaine de test) :

dig +short MX example.com
dig +short TXT example.com             # rechercher v=spf1
dig +short TXT _dmarc.example.com      # enregistrement DMARC
dig +short TXT selector._domainkey.example.com  # test DKIM (selector)

Interprétez :
	•	Absence de SPF/DKIM/DMARC → domaine vulnérable au spoofing.
	•	DMARC p=none → monitoring ; p=quarantine/p=reject → enforcement.

⸻

7) Nettoyage

Si aiosmtpd a été lancé en arrière-plan, arrêtez-le :

pkill -f aiosmtpd || true

