# Monorepo using git submodule

git submodule init
git submodule add -b main https://github.com/diegograssato/nodejs-service.git services/payments
git submodule add https://github.com/diegograssato/nodejs-service.git services/profile

git submodule set-branch --branch main services/profile
 
 