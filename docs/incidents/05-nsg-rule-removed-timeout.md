# Incident 5: Timeout after removing the NSG rule for port 80

## Symptom
Before the change, curl from my computer to the server's public IP returned the page.
After I deleted the inbound rule for port 80 in the Azure NSG, curl waited and then gave up:

```
curl: (28) Failed to connect to <server IP> port 80 after 75003 ms: Couldn't connect to server
```

75 seconds is my computer's own limit for trying to open a connection.
Nothing came back at all during that time. Not a page, not an error, not a reset.

## Cause
The NSG had no rule allowing port 80 anymore. Only SSH (22) was allowed.
The NSG sits outside the VM, so it dropped my packets silently before they
reached the server. Inside the VM everything was fine: nginx was running,
port 80 was listening and ufw allowed it. The packets just never got there.

## How I diagnosed it
I captured traffic on the server with tcpdump, filtered to port 80 and my public IP,
and sent requests from my computer.

**Positive check (NSG rule present):** the whole connection was visible.

```
<my IP>.49217 > 172.16.0.4.80: Flags [SEW]          (SYN)
172.16.0.4.80 > <my IP>.49217: Flags [S.E]          (SYN-ACK)
<my IP>.49217 > 172.16.0.4.80: Flags [.]            (ACK)
<my IP>.49217 > 172.16.0.4.80: Flags [P.] ... HTTP: GET / HTTP/1.1
172.16.0.4.80 > <my IP>.49217: Flags [P.] ... HTTP: HTTP/1.1 200 OK
... FIN from both sides
```

**Negative test (NSG rule deleted):** complete silence. Not one packet from my
computer reached the server.

My first try was wrong: I filtered on the IP shown on my Mac's network card.
That is my private home network address. My router does NAT, so the server
sees my public IP, not that one. Because of the wrong filter I saw silence and
thought it proved the problem, but I would have seen silence even if everything
was working. Only after a positive check with the correct IP was the silence
real evidence.

## Fix
I added the NSG rule for port 80 again with the same settings, and curl from my
computer got 200 again.

## Difference from Incident 1
- Incident 1 (nginx stopped): the packet reached the VM, nothing was listening
  on port 80, so the kernel answered right away with a reset (RST).
  Result: "Connection refused" in about 28 ms.
- Incident 5 (NSG rule removed): nginx was listening, but the packet never
  reached the VM. Nobody answered at all.
  Result: timeout after 75 seconds.

## Lesson
- Refused is fast and clear. Timeout is slow and silent. Timeout points to a
  firewall (NSG or ufw) dropping packets.
- When the server looks perfect from the inside but nothing works from outside,
  capture packets to see if the traffic arrives at all.
- Before trusting silence from a filter, prove the filter catches something
  when things work. Positive check first, then the negative test.