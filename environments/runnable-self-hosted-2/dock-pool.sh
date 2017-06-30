#!/bin/bash



# Add upstart files for charon and krain
mkdir -p /docker/app-logs/
echo IyF1cHN0YXJ0CmRlc2NyaXB0aW9uICJrcmFpbiIKYXV0aG9yICJKb3JnZSBTaWx2YSIKCmVudiBOUE1fQklOPS91c3IvbG9jYWwvYmluL25wbQplbnYgQVBQX0RJUj0vb3B0L3J1bm5hYmxlL2tyYWluCmVudiBMT0dfRklMRT0vZG9ja2VyL2FwcC1sb2dzL2tyYWluLmxvZwplbnYgTk9ERV9FTlY9cnVubmFibGUtc2VsZi1ob3N0ZWQtMgoKCnN0YXJ0IG9uIChsb2NhbC1maWxlc3lzdGVtcyBhbmQgbmV0LWRldmljZS11cCBJRkFDRT1ldGgwKQpzdG9wIG9uIHNodXRkb3duCgpzY3JpcHQKICB0b3VjaCAkTE9HX0ZJTEUKICBjaGRpciAkQVBQX0RJUgogIGVjaG8gJCQgPiAvdmFyL3J1bi9rcmFpbi5waWQKICBleGVjICROUE1fQklOIHN0YXJ0ID4+ICRMT0dfRklMRSAyPiYxCmVuZCBzY3JpcHQKCnByZS1zdGFydCBzY3JpcHQKICAjIERhdGUgZm9ybWF0IHNhbWUgYXMgKG5ldyBEYXRlKCkpLnRvSVNPU3RyaW5nKCkgZm9yIGNvbnNpc3RlbmN5CiAgZWNobyAiW2BkYXRlIC11ICslWS0lbS0lZFQlVC4lM05aYF0gKHN5cykgU3RhcnRpbmciID4+ICRMT0dfRklMRQplbmQgc2NyaXB0CgpwcmUtc3RvcCBzY3JpcHQKICBybSAvdmFyL3J1bi9rcmFpbi5waWQKICBlY2hvICJbYGRhdGUgLXUgKyVZLSVtLSVkVCVULiUzTlpgXSAoc3lzKSBTdG9wcGluZyIgPj4gJExPR19GSUxFCmVuZCBzY3JpcHQKCnBvc3Qtc3RhcnQgc2NyaXB0CiAgZWNobyAiPT09PT0gQXBwIHJlc3RhcnRlZCA9PT09PSIgPj4gJExPR19GSUxFCmVuZCBzY3JpcHQKCnJlc3Bhd24KcmVzcGF3biBsaW1pdCA1IDEgICAgICMgZ2l2ZSB1cCByZXN0YXJ0IGFmdGVyIDUgcmVzcGF3bnMgaW4gMSBzZWNvbmRzCg== | base64 --decode > /etc/init/krain.conf
echo IyF1cHN0YXJ0CmRlc2NyaXB0aW9uICJjaGFyb24iCmF1dGhvciAiSm9yZ2UgU2lsdmEiCgplbnYgTlBNX0JJTj0vdXNyL2xvY2FsL2Jpbi9ucG0KZW52IEFQUF9ESVI9L29wdC9ydW5uYWJsZS9jaGFyb24KZW52IExPR19GSUxFPS9kb2NrZXIvYXBwLWxvZ3MvY2hhcm9uLmxvZwplbnYgTk9ERV9FTlY9cnVubmFibGUtc2VsZi1ob3N0ZWQtMgoKZW52IERPTUFJTl9GSUxURVI9cnVubmFibGUtdGVzdC1uYXZpLTIuaW5mbwplbnYgQVBJX1VSTD1odHRwczovL2FwaS5ydW5uYWJsZS10ZXN0LW1haW4tMi5pbmZvCmVudiBEQVRBRE9HX0hPU1Q9ZGF0YWRvZwplbnYgQVBJX1RPS0VOPTUxYzYxYjc3OWYzZGU2MTZhOTYzOWNmYzQ0YTIyYzc5ZmJkOGUzMjgKZW52IFJFRElTX0hPU1Q9cmVkaXMKZW52IFJFRElTX1BPUlQ9NjM3OQplbnYgREFUQURPR19QT1JUPTgxMjUKZW52IFBPUlQ9NTMKCnN0YXJ0IG9uIChsb2NhbC1maWxlc3lzdGVtcyBhbmQgbmV0LWRldmljZS11cCBJRkFDRT1ldGgwKQpzdG9wIG9uIHNodXRkb3duCgpzY3JpcHQKICB0b3VjaCAkTE9HX0ZJTEUKICBjaGRpciAkQVBQX0RJUgogIGVjaG8gJCQgPiAvdmFyL3J1bi9jaGFyb24ucGlkCiAgZXhlYyAkTlBNX0JJTiBzdGFydCA+PiAkTE9HX0ZJTEUgMj4mMQplbmQgc2NyaXB0CgpwcmUtc3RhcnQgc2NyaXB0CiAgIyBEYXRlIGZvcm1hdCBzYW1lIGFzIChuZXcgRGF0ZSgpKS50b0lTT1N0cmluZygpIGZvciBjb25zaXN0ZW5jeQogIGVjaG8gIltgZGF0ZSAtdSArJVktJW0tJWRUJVQuJTNOWmBdIChzeXMpIFN0YXJ0aW5nIiA+PiAkTE9HX0ZJTEUKZW5kIHNjcmlwdAoKcHJlLXN0b3Agc2NyaXB0CiAgcm0gL3Zhci9ydW4vY2hhcm9uLnBpZAogIGVjaG8gIltgZGF0ZSAtdSArJVktJW0tJWRUJVQuJTNOWmBdIChzeXMpIFN0b3BwaW5nIiA+PiAkTE9HX0ZJTEUKZW5kIHNjcmlwdAoKcG9zdC1zdGFydCBzY3JpcHQKICBlY2hvICI9PT09PSBBcHAgcmVzdGFydGVkID09PT09IiA+PiAkTE9HX0ZJTEUKZW5kIHNjcmlwdAoKcmVzcGF3bgpyZXNwYXduIGxpbWl0IDUgMSAgICAgIyBnaXZlIHVwIHJlc3RhcnQgYWZ0ZXIgNSByZXNwYXducyBpbiAxIHNlY29uZHMK | base64 --decode > /etc/init/charon.conf

# Add Certs (Used for genereting Docker client keys + certs)
mkdir -p /etc/ssl/docker/
echo LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVuakNDQTRhZ0F3SUJBZ0lKQU5JRlp5OHd3U21ZTUEwR0NTcUdTSWIzRFFFQkN3VUFNSUdRTVFzd0NRWUQKVlFRR0V3SlZVekVUTUJFR0ExVUVDQk1LUTJGc2FXWnZjbTVwWVRFV01CUUdBMVVFQnhNTlUyRnVJRVp5WVc1agphWE5qYnpFUk1BOEdBMVVFQ2hNSVVuVnVibUZpYkdVeEREQUtCZ05WQkFzVEEwOXdjekVTTUJBR0ExVUVBeE1KCmJHOWpZV3hvYjNOME1SOHdIUVlKS29aSWh2Y05BUWtCRmhCdmNITkFjblZ1Ym1GaWJHVXVZMjl0TUI0WERURTIKTURVeU1qQXdNVFF4TkZvWERUSTJNRFV5TURBd01UUXhORm93Z1pBeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRApWUVFJRXdwRFlXeHBabTl5Ym1saE1SWXdGQVlEVlFRSEV3MVRZVzRnUm5KaGJtTnBjMk52TVJFd0R3WURWUVFLCkV3aFNkVzV1WVdKc1pURU1NQW9HQTFVRUN4TURUM0J6TVJJd0VBWURWUVFERXdsc2IyTmhiR2h2YzNReEh6QWQKQmdrcWhraUc5dzBCQ1FFV0VHOXdjMEJ5ZFc1dVlXSnNaUzVqYjIwd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQQpBNElCRHdBd2dnRUtBb0lCQVFDa1g0Y3dRRGNpbUd2bkpnMEhCbCtBOWRhMHpwVWpKSlZQYmJhM0Eyd0ovUzdsCmdLbFlJRDVUWE5ZcFNBZXBkbW1XTytORVhjTlZQVVlWaG9CZTREV2tKRmMrbHh0TFB5MFVPc2VaK1R2TWFjN2kKWnAway9HU0xsM0FTbG9EUGZLc0JscE9wTStPaFd2bDVqekF6U0oxbDZkR2NDRUFYRTZkaHRFVWdQTVV6ZkFmbApiVXVRN3JpOGlNQjY3S3RpeDhGSkNFcHdjemxLZmViem14dzNWeHdHaU5RU0diYnlJa251Q2s1ZUdiTVZQdGRZCkRCbCs1UjdoMFMwZW5YeFl0UHRMN0NSS3MwdUh4bThLbXZ2bzJodFNmOWJkT1Nzam5GelF2WmRCTHJyUWlwTisKaThtL1pPTDhJT3pWL1dmd3FkN1pvM3czaFVFOHJ6ckJQMENlMGYwQkFnTUJBQUdqZ2Znd2dmVXdIUVlEVlIwTwpCQllFRktvWTFLMDhoa2tXNGR0L2JvMDE1M2NjcTlzTU1JSEZCZ05WSFNNRWdiMHdnYnFBRktvWTFLMDhoa2tXCjRkdC9ibzAxNTNjY3E5c01vWUdXcElHVE1JR1FNUXN3Q1FZRFZRUUdFd0pWVXpFVE1CRUdBMVVFQ0JNS1EyRnMKYVdadmNtNXBZVEVXTUJRR0ExVUVCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVJNQThHQTFVRUNoTUlVblZ1Ym1GaQpiR1V4RERBS0JnTlZCQXNUQTA5d2N6RVNNQkFHQTFVRUF4TUpiRzlqWVd4b2IzTjBNUjh3SFFZSktvWklodmNOCkFRa0JGaEJ2Y0hOQWNuVnVibUZpYkdVdVkyOXRnZ2tBMGdWbkx6REJLWmd3REFZRFZSMFRCQVV3QXdFQi96QU4KQmdrcWhraUc5dzBCQVFzRkFBT0NBUUVBZzlneWo0OHdUaFB3NjFseFovS3BRc2I1VmhtZS9FUUQwRkU4VVI3NAp1TFhGQncwS092bXdkNU1YVURKQm1TMlF6Y3k3amE4NllFVFVuWVg2QVdweUthUzVhaHNWSHh6c05sRzhJd0hPCmxoOWdNUjFaQ2l3WVJpVlVFcTRkN1B2d3NnWi94YnppOWk0T2VYUVNzUEdEY0QyZ1NPN2ZxRSt1UUk1SlNUTTMKUlA5NjFEcnBhYk9VWVZkOC9CK1RBMGNvWWtlK1ZnSE5QTVd6Q0FmS1F2OVNVQ3F6eWtKOEd4NWNLc29mUUFjVgpVczJPcVFnSWJKdGNhNGVkczJiejZwRHhmUnV4KzdBNW4vaGZqODZZcXpRdnJIVVZSdHpzTDB1a0lPTTVHMzFaCkQ4MGxCUUxRVjdRYlRWdThwbG1aK2lzOHY3NkJTNWVDTG1LQzBVbmpFdmU3Smc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg== | base64 --decode > /etc/ssl/docker/ca.pem
echo LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpQcm9jLVR5cGU6IDQsRU5DUllQVEVECkRFSy1JbmZvOiBBRVMtMjU2LUNCQyxCNTEzRjE5M0M4NDFFQjNEMkM1MjMyNzc1ODA1NjlEQgoKbDZJMno5TmMxakltdS9ObDJEWDFPTzl6ZExWaVBNekl4RncwVHNFR2hsdzhEemdVclB1UkttL05LNTVMV1ZUUQpNWmxDREdNTGswN2tOMlJhR1NyVG10UTZzcUp3bWsrbUs4bFJkdm9pbVJhdlVFTzg2RlhhUnBLZ3FON0lEYTRqCnNkVDVJU0NCUWg2WHByZXp0Y0dtU1laN3M3YkNsdGxXMXJrazhycXNNbS96Z1g0bklZdXcwVjhDcjM0ZkRSeksKeHlSN2NiLzJyU2FUYThseEdnYWRadmFVdnBkNG9SY0RFeXVSWnFCMHNXd3hySkk3N3pnOExRSmJrVDJTR1RtcApvT3dmd0cvcDJWZjBGUnpta0RhNllXQURTYzVkd1E1bjkrSXJ6dVF5bEZ1NWY2WGFUSTNqU21JTWZqMjFNeTVkClc5bTdRMkZFTSs3eHNxTDJhOXJHQUg5d3Q5UTdFYUVEOUZLV3BEbUgxM2hoYTlmdyttV0tocjNwTUtpN3puQ3cKZWVsL1pDZlplWmE4djRiL1NydERoU0szSENNMVFQTTByempveVBNd2wvWUFvNTRRUVh0SG1OZHR6cnRxNlhrTApGT1dpVkNCSkt6cDQwbnVScFJSU25mS09xbmdQcWRGS1NTUWlhNkZUOG1QZmZoTDlWTVlaMnc3REJvbDRJWlRzCjJQam8vQ3hXWUdQMmhvWlhLQ2tVKzVBTmZ4MU1TMmNZaEN5QytPTUNNczNOSVo0OVhnOS8zaE5Ublp3SEE1eGIKNHB0R09JSTF5cG9SbUtaZzFkb0xqekl1dXBIVC84ZkpVZm5lME9ybDhXSU9zYWxlanNINnkzeDRpUHFKVFcwVApKWFRhM3UyOG1pRGhiNm9qSitDckx2NjBGTVpwbkU0cjVDbFBDTVVOWFpXc3NYWXhER21uQmp0cWFnc09TL0hECmdNLytKSFhIdHBDMG5jaFVXaUowN3RuYUxabHVLanVBTlJ2eDlSU1ZsVTdyN3hjM0gzc0RVNUJYbjREUXRmdGgKK2xGWkRGWnRLNWJOSWg0ZHFHYk9WM0VZSS9qWjEwSDBMNnZDTXpqbE9mTXVDQjhXa1pCVmNMOUsycThkUS9rdAp2RWlMYzJjeUZGZHRqdFFNYTFLVnBvQ2U0TE9kai9lTVZjdzhsQnZlNU9XMis1WVlESjFFdlUwSEltcEEwTVVXCm82WWc2TFhxWnFWRGpKRkZsT2tBSU83SUlPYmdCcGVYSm9SWVFxRmJQQXI1Mm9WZ1RIRFBIVU9UU1lnVTZ6SHgKdTRNc25CWXpwU0FyaWhzaGRzUURYUGd2RnZSQ0J3SFp5MUZJNTVpekhBWVJ0UHdWZXJyTnpWaytCZFl0cGxwQQovbVh1WmZlcHNRbjZtWmFLMFNEcEloR1VWS1QrcUVnY01KSVowVjNwNVViK1hnK0lCSUlrR0V6dFkyTElSWGtGCjBtSEJLTm9ZY0NzQ044Y1pqMkp1RzN6a2FvcGQ2ZW1KRkRVQmVCOEVlejdjRnlJM2ZmNnh5TVRtVXlybUJ6Z3EKUDVpdHhyeFVYWkk0blpRVThkcmoyaE8zdDdrVnZ2c2wzQTVkbzZmT0lsdHNGSUV5RTlWZ3RHR1FzUTZSRURHOApJYUdJSVdLYXhwalpCQVRxOVM1VFd6QUt4N05tQ2l0TFA3K2F4TjA5aWkvMDVoZVZmNlhlZEJ4cFI3RjhLbG51CkRmMzdnNjRkbmd1SktWeXcxRHE2Qmd0SjYxS1pvN05JTkhjaVJaU3c3bDQvb2RLWG5STGtRRVBlOXhma0pScUIKRjR5OXpGNGFiMVo1M1JqZHJFbnBQamtHRXNVRUFSYnVQcTQ2TU52R2YzM3hNWElNbjBWWVpaVUdobXNDSjgvYQo0MExCbkc1S0lwZ0xBcldmVDUybTRCTXAyaUZPdGxVZHZ6MWFQbXFITmIvamNxSVRDVm0zZ3VrRVcvVnBVOURvCnVUOTN2eUg3ZWd5TjRwdVdqTUUzaC83VXM5ekUzWFVDQ0VxQUJkUzJxQXVjMC9EM2JybDgrdUFnQ1VCMVArQVIKMmhjRFg1aU9laGJWaVRJODZqWEFCaVltNzg3U2Zsak4xcXhQNE9sOHk4cUMvakZOSjRWRVQ3Qm1vdjU3eERxUAotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo= | base64 --decode > /etc/ssl/docker/ca-key.pem
echo cHVycGxlNGx5ZmUK | base64 --decode > /etc/ssl/docker/pass
chmod -R 0440 /etc/ssl/docker/

# Start services
start amazon-ssm-agent
service krain start
service charon start
