## 🚀 Script de vérification DNS (SPF, DKIM, DMARC)

Voici la version améliorée du script `check_dns.sh` :  

```bash
#!/usr/bin/env bash
# check_dns.sh – SPF / DKIM / DMARC quick check (multi-selectors)
# (c) 2025 Virginie Lechene – MIT
# Usage: ./check_dns.sh <domaine> [selector1,selector2,...]
set -euo pipefail

DOMAIN="${1:-}"
[ -n "$DOMAIN" ] || { echo "Usage: $0 <domaine> [selectors]"; exit 2; }

# selectors par défaut si non fournis
SEL_CSV="${2:-default,selector1,selector,mail,google,dkim}"
IFS=',' read -r -a SELECTORS <<< "$SEL_CSV"

echo "🔎 Vérification DNS: $DOMAIN"
echo "----------------------------------------"

# SPF
echo -e "\n[SPF]"
SPF=$(dig +short TXT "$DOMAIN" | grep -i 'v=spf' || true)
echo "${SPF:-❌ Aucun SPF trouvé}"

# DKIM (multi-selectors)
echo -e "\n[DKIM]"
FOUND_DKIM=0
for sel in "${SELECTORS[@]}"; do
  VAL=$(dig +short TXT "${sel}._domainkey.${DOMAIN}" || true)
  if [ -n "$VAL" ]; then
    echo "✔ ${sel}._domainkey.${DOMAIN} → ${VAL}"
    FOUND_DKIM=1
  fi
done
[ "$FOUND_DKIM" -eq 1 ] || echo "❌ Aucun DKIM trouvé pour: ${SEL_CSV}"

# DMARC
echo -e "\n[DMARC]"
DMARC=$(dig +short TXT "_dmarc.${DOMAIN}" | grep -i 'v=DMARC' || true)
echo "${DMARC:-❌ Aucun DMARC trouvé}"

echo -e "\n✅ Terminé"
