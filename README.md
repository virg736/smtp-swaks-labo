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
- `README.md` — introduction (ce fichier).
- `docs/demo_smtp_swaks.md` — guide pas-à-pas (installation, création serveur local, tests).
- `docs/protections_email.md` — explication SPF/DKIM/DMARC/TLS et pourquoi protéger.
- `scripts/run_demo.sh` — script safe (local only) : démarre serveur local, lance swaks, sauvegarde traces.
- `artifacts/` — sorties de tests (texte).
- `SAFE_NOTICE.md` / `ROE_MINI.md` — notices d’usage pédagogique.

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
