#!/usr/bin/env bash
# check_dns.sh - Vérifie SPF, DKIM et DMARC pour un domaine
# Copyright (c) 2025 Virginie Lechene
# Licence: MIT
# Usage: ./check_dns.sh example.com

DOMAIN=$1

if [ -z "$DOMAIN" ]; then
  echo "Usage: $0 <domaine>"
  exit 1
fi

echo "🔍 Vérification DNS pour le domaine: $DOMAIN"
echo "---------------------------------------"

# SPF
echo -e "\n[SPF]"
dig +short TXT $DOMAIN | grep "v=spf" || echo "⚠️ Aucun SPF trouvé"

# DKIM (test avec selector 'default')
echo -e "\n[DKIM]"
dig +short TXT default._domainkey.$DOMAIN || echo "⚠️ Aucun DKIM trouvé (selector default)"

# DMARC
echo -e "\n[DMARC]"
dig +short TXT _dmarc.$DOMAIN | grep "v=DMARC" || echo "⚠️ Aucun DMARC trouvé"

echo -e "\n✅ Vérification terminée"
