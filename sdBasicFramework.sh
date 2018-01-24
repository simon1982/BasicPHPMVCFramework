#!/bin/bash
#
# Script Name: sdBasicFramework.sh
#
# Author: Szymon Domanski
# Date : 24/01/2018
#
# Version : 1.0
#
# Description: This is the generator of a simple php framework in the MVC model.
#
# Run Information: This script need php CLI in the system. 
#
echo "This will create empty framework tree"

mkdir -p vendor/assets/bootstrap/css
mkdir -p vendor/assets/bootstrap/js
mkdir -p vendor/assets/bootstrap/fonts
mkdir -p vendor/assets/images
mkdir -p vendor/opt
mkdir -p vendor/templates
mkdir -p _temp
cd _temp
wget https://github.com/twbs/bootstrap/releases/download/v3.3.7/bootstrap-3.3.7-dist.zip
unzip -q bootstrap-3.3.7-dist.zip
cd bootstrap-3.3.7-dist
cp -r * ../../vendor/assets/bootstrap
cd ..
cd ..
 echo "Please enter project revers domain e.g.: com.szymondomanski.project"
    read name
    mkdir -p vendor/$name
    echo "<?php $config = array('current_template' => 'vendor/templates/main.tpl');" >> vendor/opt/config.php
 	echo "<?php
	
	date_default_timezone_set('Europe/Warsaw');
	session_start();
    define(\"ROOT\", __DIR__ .\"/\");
    require_once('autoload.php');
    require_once(ROOT.'vendor/opt/config.php');
    \$router = New App\Router();
    \$router->route(\$_SERVER['REQUEST_URI'],\$config);"  >> index.php
    echo "<?php
	foreach ( glob(ROOT.'vendor/"$name"/*') as \$vendor){
    	require_once \$vendor;
	}" >> autoload.php
	echo "<IfModule mod_rewrite.c>
			RewriteEngine On
			RewriteBase /
			RewriteRule ^index\.php$ - [L]
			RewriteCond %{REQUEST_FILENAME} !-f
			RewriteCond %{REQUEST_FILENAME} !-d
			RewriteRule . /index.php [L]
			</IfModule>" >> .htaccess

	echo "<?php

		namespace App;
		use App\App;

		class Router{
			
			public function route(\$uri,\$config){
				
				switch (\$uri) {
					case '/base64-encode.html':
						\$this->setLog('base64-encode.html#output');
						\$App = New App();
						\$App->pageview('encode',\$config);
						break;
					case '/base64-decode.html':
						\$this->setLog('base64-decode.html#output');
						\$App = New App();
						\$App->pageview('decode',\$config);
						break;
					case '/about.html':
						\$this->setLog('about.html');
						\$App = New App();
						\$App->pageview('about',\$config);
						break;
					case '/':
						\$this->setLog('/');
						\$App = New App();
						\$App->pageview('encode',\$config);
						break;
					default:
						\$this->setLog($_SERVER['REQUEST_URI']);
						\$App = New App();
						\$App->pageview('encode',\$config);
					break;
					
				}
			}

			public function setLog(\$input){
				file_put_contents('log_file_'.date(\"d-m-Y\").'.log',date(\"H:i:s\").' : '.\$input.\"\n\" , FILE_APPEND | LOCK_EX);
			}
		}" >> vendor/$name/class.router.php
		echo "<?php


namespace App;



    class Template {
        /**
         * The filename of the template to load.
         *
         * @access protected
         * @var string
         */
        protected \$file;

        /**
         * An array of values for replacing each tag on the template (the key for each value is its corresponding tag).
         *
         * @access protected
         * @var array
         */
        protected \$values = array();

        /**
         * Creates a new Template object and sets its associated file.
         *
         * @param string \$file the filename of the template to load
         */
        public function __construct(\$file) {
            \$this->file = \$file;
        }

        /**
         * Sets a value for replacing a specific tag.
         *
         * @param string \$key the name of the tag to replace
         * @param string \$value the value to replace
         */
        public function set(\$key, \$value) {
            \$this->values[\$key] = \$value;
        }

        /**
         * Outputs the content of the template, replacing the keys for its respective values.
         *
         * @return string
         */
        public function output() {
            /**
             * Tries to verify if the file exists.
             * If it doesn't return with an error message.
             * Anything else loads the file contents and loops through the array replacing every key for its value.
             */
            if (!file_exists(\$this->file)) {
                return \"Error loading template file (\$this->file).<br />\";
            }
            \$output = file_get_contents(\$this->file);

            foreach (\$this->values as \$key => \$value) {
                \$tagToReplace = \"[@\$key]\";
                \$output = str_replace(\$tagToReplace, \$value, \$output);
            }

            return \$output;
        }

        /**
         * Merges the content from an array of templates and separates it with \$separator.
         *
         * @param array \$templates an array of Template objects to merge
         * @param string \$separator the string that is used between each Template object
         * @return string
         */
        static public function merge(\$templates, \$separator = \"\n\") {
            /**
             * Loops through the array concatenating the outputs from each template, separating with \$separator.
             * If a type different from Template is found we provide an error message.
             */
            \$output = \"\";

            foreach (\$templates as \$template) {
                \$content = (get_class(\$template) !== \"Template\")
                    ? \"Error, incorrect type - expected Template.\"
                    : \$template->output();
                \$output .= \$content . \$separator;
            }

            return \$output;
        }
    }

?>" >> vendor/$name/class.template.php

	echo "<?php

namespace App;

use App\Router;

class App{
	
	public function pageview(\$page,\$config){
		\$log = New Router();
		\$log->setLog('App : page :'.\$page);
		\$t = array('encode' => 'Base64 Encode Tool - szymondomanski.com','decode' => 'Base64 Decode Tool - szymondomanski.com', 'about' => 'Base64 About - szymondomanski.com');
		
		\$template = new Template(ROOT.\$config['current_template']);
		\$template2 = new Template(ROOT.'vendor/templates/'.\$page.'.tpl');
		\$template->set('title',\$t[\$page]);
		\$template->set('content',\$template2->output());
		echo \$template->output();
	}
}" >> vendor/$name/class.app.php
