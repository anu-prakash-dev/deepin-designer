/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2016 Deepin, Inc.
 *               2011 ~ 2016 Wang Yong
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 * Maintainer: Wang Yong <wangyong@deepin.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 

using GLib;
using Gee;

namespace Config {
    public class Config : GLib.Object {
        public KeyFile config_file;
        public string config_file_path = Utils.get_config_file_path("config.conf");
        
        public signal void update();
        
        public Config() {
            config_file = new KeyFile();

            var file = File.new_for_path(config_file_path);
            if (!file.query_exists()) {
                init_config();
            } else {
                load_config();
            }
        }
		
        public void init_config() {
            config_file.set_integer("advanced", "window_width", 0);
            config_file.set_integer("advanced", "window_height", 0);

            save();
        }

        public void check_string(string group, string key, string value) {
            try {
                if (!config_file.has_group(group) || !config_file.has_key(group, key)) {
                    config_file.set_string(group, key, value);
                } else {
                    config_file.get_string(group, key);
                }
            } catch (KeyFileError e) {
                print("check_string: %s\n", e.message);
                
                config_file.set_string(group, key, value);
                print("Reset [%s] %s with %s\n", group, key, value);
            }
        }
        
        public void check_integer(string group, string key, int value) {
            try {
                if (!config_file.has_group(group) || !config_file.has_key(group, key)) {
                    print("** start!\n");
                    config_file.set_integer(group, key, value);
                } else {
                    config_file.get_integer(group, key);
                }
            } catch (KeyFileError e) {
                print("check_integer: %s\n", e.message);
                
                config_file.set_integer(group, key, value);
                print("Reset [%s] %s with %i\n", group, key, value);
            }
        }

        public void check_double(string group, string key, double value) {
            try {
                if (!config_file.has_group(group) || !config_file.has_key(group, key)) {
                    config_file.set_double(group, key, value);
                } else {
                    config_file.get_double(group, key);
                }
            } catch (KeyFileError e) {
                print("check_double: %s\n", e.message);

                config_file.set_double(group, key, value);
                print("Reset [%s] %s with %f\n", group, key, value);
            }
        }
        
        public void check_boolean(string group, string key, bool value) {
            try {
                if (!config_file.has_group(group) || !config_file.has_key(group, key)) {
                    config_file.set_boolean(group, key, value);
                } else {
                    config_file.get_boolean(group, key);
                }
            } catch (KeyFileError e) {
                print("check_boolean: %s\n", e.message);

                config_file.set_boolean(group, key, value);
                print("Reset [%s] %s with %s\n", group, key, value.to_string());
            }
        }
        
        public void check_config() {
            try {
                config_file.load_from_file(config_file_path, KeyFileFlags.NONE);
            } catch (Error e) {
				if (!FileUtils.test(config_file_path, FileTest.EXISTS)) {
					print("Config check_config: %s\n", e.message);
				}
			}
            
            check_integer("advanced", "window_width", 0);
            check_integer("advanced", "window_height", 0);
            
            save();
        }
        
        public void load_config() {
            try {
                check_config();
                
                config_file.load_from_file(config_file_path, KeyFileFlags.NONE);
            } catch (Error e) {
				if (!FileUtils.test(config_file_path, FileTest.EXISTS)) {
					print("Config load_config: %s\n", e.message);
				}
			}
        }
        
        public void save() {
            try {
			    Utils.touch_dir(Utils.get_config_dir());
				
                config_file.save_to_file(config_file_path);
            } catch (GLib.FileError e) {
				if (!FileUtils.test(config_file_path, FileTest.EXISTS)) {
					print("save: %s\n", e.message);
				}
			}
        }
    }
}