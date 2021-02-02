# must be changed in ruby script: cloud_uri = 'ues:DTC-BT:DEMO'

# DEV scale
## Scale on PRODUCTION slot
```
# echo
ruby duplicate_container.rb ues:[99923616732520257]:[600ac92af76e02be262152a6]:[600f201d1aba15374326b30d] --count=2 --require-different-hosts --credentials=/Users/nwm/.uu/22-7709-1
ruby duplicate_container.rb ues:[99923616732520257]:[600ac92af76e02be262152a6]:[600f201d1aba15374326b30d] BETA --count=2 --require-different-hosts --credentials=/Users/nwm/.uu/22-7709-1
```
