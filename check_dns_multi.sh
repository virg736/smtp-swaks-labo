#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  check_dns_multi.sh — Vérification DNS (SPF, DKIM multi-sélecteurs, DMARC)
#  (c) 2025 Virginie Lechene
#  SPDX-License-Identifier: MIT
#
#  Usage:
#    ./check_dns_multi.sh <domaine> [selector1,selector2,...]
#
#  Exemple:
#    ./check_dns_multi.sh gmail.com
#    ./check_dns_multi.sh exemple.fr default,mail,google,dkim
#
#  Remarques:
#  - Lecture seule: utilise uniquement `dig +short TXT`.
#  - Les sélecteurs DKIM sont optionnels; une liste par défaut est utilisée si absents.
# -----------------------------------------------------------------------------

set -euo pipefail

# -------- Arguments -----------------------------------------------------------
DOMAIN="${1:-}"
if [[ -z "$DOMAIN" ]]; then
  echo "Usage: $0 <domaine> [selector1,selector2,...]" >&2
  exit 1
fi

# Liste de sélecteurs DKIM (CSV) : valeur par défaut si non fournie
SEL_CSV="${2:-default,selector1,selector,mail,google,dkim}"
IFS=',' read -r -a SELECTORS <<< "$SEL_CSV"

echo "Vérification DNS : $DOMAIN"
echo "-------------------------------------------------------------"

# -------- SPF ----------------------------------------------------------------
echo -e "\n[SPF]"
SPF=$(dig +short TXT "$DOMAIN" | grep -i 'v=spf1' || true)
if [[ -n "$SPF" ]]; then
  echo "SPF trouvé :"
  echo "$SPF"
else
  echo "Aucun SPF trouvé"
fi

# -------- DKIM (multi-sélecteurs) --------------------------------------------
echo -e "\n[DKIM]"
FOUND_DKIM=0
for sel in "${SELECTORS[@]}"; do
  rec="${sel}._domainkey.${DOMAIN}"
  VAL=$(dig +short TXT "$rec" || true)
  if [[ -n "$VAL" ]]; then
    echo "DKIM trouvé pour ${rec}"
    FOUND_DKIM=1
  else
    echo "Pas de clé pour ${rec}"
  fi
done
if [[ "$FOUND_DKIM" -eq 0 ]]; then
  echo "Aucun DKIM trouvé pour les sélecteurs fournis"
fi

# -------- DMARC ---------------------------------------------------------------
echo -e "\n[DMARC]"
DMARC=$(dig +short TXT "_dmarc.${DOMAIN}" | grep -i 'v=DMARC1' || true)
if [[ -n "$DMARC" ]]; then
  echo "DMARC trouvé :"
  echo "$DMARC"
  pol=$(echo "$DMARC" | tr -d '"' | tr ';' '\n' | awk -F= '$1~"^p$"{print $2}')
  if [[ -n "${pol:-}" ]]; then
    echo "Politique: $pol"
  fi
else
  echo "Aucun DMARC trouvé"
fi

echo -e "\nVérification terminée"