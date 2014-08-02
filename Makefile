PATH := $(PATH):$(PWD)/node_modules/.bin

.PHONY: gruntfile clean package.json

all: clean update gruntfile package.json polymer-expressions.min.js

clean:
	rm -rf tools; true
	rm -rf node_modules/semver; true
	rm -rf node_modules/grunt-cli; true
	rm -rf node_modules/underscore-cli; true
	rm polymer-expressions.min.js; true
	git checkout .gitignore
	git checkout gruntfile.js
	git checkout package.json

update:
	git ls-remote polymer || git remote add polymer git@github.com:Polymer/polymer-expressions.git
	git pull polymer master

tools/:
	git clone git@github.com:Polymer/tools.git

gruntfile:
	cat  gruntfile.js | sed s/\\.\\.\\/tools/\\.\\/tools/g > _gruntfile.js
	cat _gruntfile.js > gruntfile.js
	rm  _gruntfile.js

polymer-expressions.min.js: gruntfile node_modules/grunt-cli tools/
	rm .gitignore
	$$(which grunt) concat

package.json: node_modules/underscore-cli node_modules/semver
	cat package.json \
		| underscore extend '{"main":"index.js"}' \
		| underscore extend '{"files":["polymer-expressions.min.js","index.js"]}' \
		| underscore extend '{"version":"'$$(semver $$(curl https://api.github.com/repos/Polymer/polymer-expressions/tags \
			| underscore select .name --outfmt text) \
			| tail -n 1)'"}' \
		| underscore print --outfmt stringify \
		> _package.json
	cat _package.json > package.json
	rm  _package.json

node_modules/grunt-cli:
	npm install grunt-cli

node_modules/underscore-cli:
	npm install underscore-cli

node_modules/semver:
	npm install semver
