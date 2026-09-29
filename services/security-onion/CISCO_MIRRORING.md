# Cisco speiling mot Security Onion

Bruk denne filen som mønster, ikke som blind copy/paste. SPAN-/RSPAN-/ERSPAN-syntaks og begrensninger varierer mellom modeller og IOS-versjoner.

## Lokal SPAN

```cisco
monitor session 1 source vlan 20,30,40 both
monitor session 1 destination interface GigabitEthernet0/10
```

Mirror interface kobles direkte til Security Onion sin sniff-NIC og skal ikke brukes som vanlig accessport samtidig.

## ERSPAN-prinsipp

```text
Site source switch
   -> ERSPAN over routet transport
   -> hub/destination device
   -> lokal mirror destination port
   -> Security Onion sniff NIC
```

Verifiser alltid:

- at source-plattformen støtter ønsket ERSPAN-type
- at destination-plattformen kan terminere ERSPAN slik designet krever
- at MTU/fragmentering ikke gir pakketap
- at sensoren faktisk ser begge trafikkretninger
- at speiling ikke oversubscriber destination-porten
