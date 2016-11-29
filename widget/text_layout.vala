using Layouts;

namespace Layouts {
    public class TextLayout : Layout {
        public string text = "Type \nsomething\ntest";
        public int text_size = 20;
        public int line_height = 42;
        public Gdk.RGBA text_color;
        public int cursor_width = 2;
        
        public Gdk.RGBA insert_cursor_color;
        public int insert_cursor_index = 0;
		public int insert_cursor_trailing = 0;
		public int insert_cursor_column_offset = 0;

        public Gdk.RGBA select_cursor_color;
        public int select_cursor_index = 0;
        public int select_cursor_trailing = 0;
        public int select_cursor_column_offset = 0;
        
		public Pango.Layout layout;		
            
        public TextLayout() {
            text_color = Utils.hex_to_rgba("#000000", 1.0);
            
            insert_cursor_color = Utils.hex_to_rgba("#ff1e00", 1.0);
            select_cursor_color = Utils.hex_to_rgba("#00ffff", 1.0);
        }
            
        public override void draw_layout(Cairo.Context cr) {
            cr.save();
            
            // Init text.
            var font_description = new Pango.FontDescription();
            font_description.set_size((int)(text_size * Pango.SCALE));
            
            layout = Pango.cairo_create_layout(cr);
            layout.set_font_description(font_description);
            layout.set_text(text, text.length);
            layout.set_alignment(Pango.Alignment.LEFT);
    
            int text_width, text_height;
            layout.get_pixel_size(out text_width, out text_height);
                
            width = text_width;
            height = text_height;
    
            int render_y;
            render_y = y + int.max(0, (height - text_height) / 2);
            
            // Draw select bound.
            if (!is_create_finish) {
                if (insert_cursor_index != select_cursor_index || insert_cursor_trailing != select_cursor_trailing) {
                    int select_start_index = int.min(insert_cursor_index, select_cursor_index);
                    int select_start_trailing = int.min(insert_cursor_trailing, select_cursor_trailing);
                    int[] select_start_index_coordinate = index_to_line_x(select_start_index, select_start_trailing);
                    int sx = x + select_start_index_coordinate[1] / Pango.SCALE;
                    int sy = y + select_start_index_coordinate[0] * line_height;
                    
                    int select_end_index = int.max(insert_cursor_index, select_cursor_index);
                    int select_end_trailing = int.max(insert_cursor_trailing, select_cursor_trailing);
                    int[] select_end_index_coordinate = index_to_line_x(select_end_index, select_end_trailing);
                    int ex = x + select_end_index_coordinate[1] / Pango.SCALE;
                    int ey = y + select_end_index_coordinate[0] * line_height;
                    
                    Utils.set_context_color(cr, select_cursor_color);
                    if (sy == ey) {
                        Draw.draw_rectangle(cr, sx, sy, ex - sx, line_height);
                    } else {
                        cr.move_to(sx, sy);
                        cr.line_to(x + text_width, sy);
                        cr.line_to(x + text_width, ey);
                        cr.line_to(ex, ey);
                        cr.line_to(ex, ey + line_height);
                        cr.line_to(x, ey + line_height);
                        cr.line_to(x, sy + line_height);
                        cr.line_to(sx, sy + line_height);
                        cr.close_path();
                        
                        cr.fill();
                    }
                }
            }

            // Draw text.
            Utils.set_context_color(cr, text_color);
            cr.move_to(x, render_y);
            Pango.cairo_update_layout(cr, layout);
            Pango.cairo_show_layout(cr, layout);
            
            // Draw cursor.
            if (!is_create_finish) {
                int[] index_coordinate = index_to_line_x(insert_cursor_index, insert_cursor_trailing);
                int line = index_coordinate[0];
                int x_pos = index_coordinate[1];
                Utils.set_context_color(cr, insert_cursor_color);
                Draw.draw_rectangle(cr, x + x_pos / Pango.SCALE, y + line * line_height, cursor_width, line_height);
            }
            
            cr.restore();
        }
        
        public bool handle_key_press(Gdk.EventKey key_event) {
            string keyname = Keymap.get_keyevent_name(key_event);

            if (Keymap.is_char(key_event)) {
                insert_char(Keymap.get_char_name(key_event));
                return true;
            } else if (keyname == "Ctrl + f" || keyname == "Right") {
                forward_char();
                return true;
            } else if (keyname == "Ctrl + b" || keyname == "Left") {
                backward_char();
                return true;
            } else if (keyname == "Ctrl + n" || keyname == "Down") {
                next_line();
                return true;
            } else if (keyname == "Ctrl + p" || keyname == "Up") {
                prev_line();
                return true;
            } else if (keyname == "Home") {
				move_beginning_of_line();
                return true;
			} else if (keyname == "End") {
				move_end_of_line();
                return true;
			} else if (keyname == "Ctrl + a") {
                select_all();
                return true;
            } else if (keyname == "Shift + Left") {
                select_backward_char();
                return true;
            } else if (keyname == "Shift + Right") {
                select_forward_char();
                return true;
            } else if (keyname == "Shift + Up") {
                select_prev_line();
                return true;
            } else if (keyname == "Shift + Down") {
                select_next_line();
                return true;
            } else if (keyname == "Shift + Home") {
                select_to_beginning_of_line();
                return true;
            } else if (keyname == "Shift + End") {
                select_to_end_of_line();
                return true;
            } else if (keyname == "Alt + f") {
				forward_word();
                return true;
			} else if (keyname == "Alt + b") {
				backward_word();
                return true;
			} else if (keyname == "Delete") {
                delete_selected();
                return true;
            } else if (keyname == "Backspace") {
                backspace_delete();
                return true;
            } else if (keyname == "Ctrl + v") {
                paste();
                return true;
            } else if (keyname == "Esc") {
                is_create_finish = true;
                return true;
            } else if (keyname == "Enter") {
                insert_char("\n");
                return true;
            } else if (keyname == "Space") {
                insert_char(" ");
                return true;
            }
            
            return false;
        }
        
        public void insert_char(string char) {
            if (insert_cursor_index != select_cursor_index || insert_cursor_trailing != select_cursor_trailing) {
                delete_selected();
            }

            text = "%s%s%s".printf(text.substring(0, insert_cursor_index), char, text.substring(insert_cursor_index, text.char_count() - insert_cursor_index));
            
            insert_cursor_index += char.char_count();
            
            sync_cursors();
        }
        
        public void paste() {
            if (insert_cursor_index != select_cursor_index || insert_cursor_trailing != select_cursor_trailing) {
                delete_selected();
            }

            var clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD);
            var current_clipboard_text = clipboard.wait_for_text();

            text = "%s%s%s".printf(text.substring(0, insert_cursor_index), current_clipboard_text, text.substring(insert_cursor_index, text.char_count() - insert_cursor_index));
            
            insert_cursor_index += current_clipboard_text.char_count();
            
            sync_cursors();
        }
        
        public void delete_selected() {
            int select_start_index = int.min(insert_cursor_index, select_cursor_index);
            int select_start_trailing = int.min(insert_cursor_trailing, select_cursor_trailing);
            int select_end_index = int.max(insert_cursor_index, select_cursor_index);
            
            text = "%s%s".printf(text.substring(0, select_start_index), text.substring(select_end_index, text.char_count() - select_end_index));
            
            insert_cursor_index = select_start_index;
            insert_cursor_trailing = select_start_trailing;
            
            sync_cursors();
        }
        
        public void backspace_delete() {
            if (insert_cursor_index != select_cursor_index || insert_cursor_trailing != select_cursor_trailing) {
                delete_selected();
            } else {
                int new_index, new_trailing;
                layout.move_cursor_visually(true, insert_cursor_index, insert_cursor_trailing, -1, out new_index, out new_trailing);
                
                print("***** %i(%i) %i(%i) %i\n", insert_cursor_index, insert_cursor_trailing, new_index, new_trailing, text.char_count());
                if (new_index >= 0) {
                    text = "%s%s".printf(text.substring(0, new_index), text.substring(insert_cursor_index, text.char_count() - insert_cursor_index));
                    
                    insert_cursor_index = new_index;
                    insert_cursor_trailing = new_trailing;
                    
                    sync_cursors();
                }
            }
        }
        
        public void select_all() {
            select_cursor_index = 0;
            select_cursor_trailing = 0;
            
            insert_cursor_index = text.char_count() - 1;
            insert_cursor_trailing = 1;
        }
        
        public void select_forward_char() {
            forward_char_internal();
        }
        
        public void select_backward_char() {
            backward_char_internal();
        }
        
        public void select_next_line() {
            next_line_internal();
        }
        
        public void select_prev_line() {
            prev_line_internal();
        }
        
        public void select_to_beginning_of_line() {
            move_beginning_of_line_internal();
        }
        
        public void select_to_end_of_line() {
            move_end_of_line_internal();
        }
        
        public void sync_cursors() {
            select_cursor_index = insert_cursor_index;
            select_cursor_trailing = insert_cursor_trailing;
        }
        
        public void forward_char() {
            forward_char_internal();
            sync_cursors();
        }
        
		public void forward_char_internal() {
			int new_index, new_trailing;
			layout.move_cursor_visually(true, insert_cursor_index, insert_cursor_trailing, 1, out new_index, out new_trailing);
			
			if (new_index != int.MAX) {
				insert_cursor_index = new_index;
				insert_cursor_trailing = new_trailing;
			}
        }
        
        public void backward_char() {
            backward_char_internal();
            sync_cursors();
        }
        
        public void backward_char_internal() {
			int new_index, new_trailing;
			layout.move_cursor_visually(true, insert_cursor_index, insert_cursor_trailing, -1, out new_index, out new_trailing);
			
			if (new_index >= 0) {
				insert_cursor_index = new_index;
				insert_cursor_trailing = new_trailing;
			}
        }
        
		public void forward_word() {
			forward_skip_word_chars();
			forward_to_word_bound();
        }
		
		public void backward_word() {
			backward_skip_word_chars();
			backward_to_word_bound();
        }
		
        public void next_line() {
            next_line_internal();
            sync_cursors();
        }
        
        public void next_line_internal() {
			int line = get_cursor_line();

			int new_index, new_trailing;
			layout.xy_to_index(insert_cursor_column_offset, (line + 1) * line_height * Pango.SCALE, out new_index, out new_trailing);
			insert_cursor_index = new_index;
			insert_cursor_trailing = new_trailing;
        }
        
        public void prev_line() {
            prev_line_internal();
            sync_cursors();
        }
        
        public void prev_line_internal() {
			int line = get_cursor_line();

			int new_index, new_trailing;
			layout.xy_to_index(insert_cursor_column_offset, (line - 1) * line_height * Pango.SCALE, out new_index, out new_trailing);
			insert_cursor_index = new_index;
			insert_cursor_trailing = new_trailing;
        }
		
        public void move_beginning_of_line() {
            move_beginning_of_line_internal();
            sync_cursors();
        }
        
		public void move_beginning_of_line_internal() {
			int[] line_bound = find_line_bound();
			insert_cursor_index = line_bound[0];
			insert_cursor_trailing = 0;
		}
        
        public void move_end_of_line() {
            move_end_of_line_internal();
            sync_cursors();
        }
		
		public void move_end_of_line_internal() {
			int[] line_bound = find_line_bound();
			insert_cursor_index = line_bound[1];
			insert_cursor_trailing = 1;
		}
		
		public bool is_indentation_chars(unichar c, bool is_skip) {
			unichar[] indentation_chars = {' ', '\t'};
			
			if (is_skip) {
				return !(c in indentation_chars);
			} else {
				return c in indentation_chars;
			}
		}
		
		public bool is_word_bound_chars(unichar c, bool is_skip) {
			unichar[] word_chars =  {' ', '_', '-', ',', '.',
									 '\n', '\t', ';', ':', '!',
									 '|', '&', '>', '<', '{', '}',
									 '[', ']', '#', '\"', '(', ')',
									 '=', '*', '^', '%', '$', '@',
									 '?', '/', '~', '`'};
			
			if (is_skip) {
				return !(c in word_chars);
			} else {
				return c in word_chars;
			}
		}
		
		public void forward_to_word_bound(bool is_skip=false) {
			bool reach_end = false;
			unichar c = 0;
			bool found_next_char = true;

			found_next_char = text.get_next_char(ref insert_cursor_index, out c);
			while (found_next_char && !reach_end) {
				if (is_word_bound_chars(c, is_skip)) {
                    if (c != '\n') {
                        backward_char();
                    }
                    
					reach_end = true;
				} else {
					found_next_char = text.get_next_char(ref insert_cursor_index, out c);
					reach_end = !found_next_char;
				}
			}
		}

		public void forward_skip_indentation_chars() {
			bool reach_end = false;
			unichar c = 0;
			bool found_next_char = true;

			found_next_char = text.get_next_char(ref insert_cursor_index, out c);
			while (found_next_char && !reach_end) {
				if (is_indentation_chars(c, true)) {
					backward_char();
					reach_end = true;
				} else {
					found_next_char = text.get_next_char(ref insert_cursor_index, out c);
					reach_end = !found_next_char;
				}
			}
		}

		public void forward_skip_word_chars() {
			forward_to_word_bound(true);
		}
		
		public void backward_skip_word_chars() {
			backward_to_word_bound(true);
		}
		
		public void backward_to_word_bound(bool is_skip=false) {
			bool reach_end = false;
			unichar c = 0;
			bool found_prev_char = true;

			found_prev_char = text.get_prev_char(ref insert_cursor_index, out c);
			while (found_prev_char && !reach_end) {
				if (is_word_bound_chars(c, is_skip)) {
					forward_char();
					reach_end = true;
				} else {
					found_prev_char = text.get_prev_char(ref insert_cursor_index, out c);
					reach_end = !found_prev_char;
				}
			}
		}
		
		public int[] find_line_bound() {
			int[] line_bound = new int[2];
			
			line_bound[0] = text.substring(0, insert_cursor_index).last_index_of_char('\n') + 1;
			line_bound[1] = text.index_of_char('\n', insert_cursor_index);
			
			if (line_bound[1] == -1) {
				line_bound[1] = text.char_count() - 1;
			}
			
			return line_bound;
		}
		
        public int[] index_to_line_x(int index, int trailing) {
			int line, x_pos;
			bool is_trailing = trailing > 0;
			layout.index_to_line_x(index, is_trailing, out line, out x_pos);
			
			return {line, x_pos};
		}
            
		public int get_cursor_line() {
			return index_to_line_x(insert_cursor_index, insert_cursor_trailing)[0];
		}
        
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            can_draw = true;
                
            x = drag_start_x;
            y = drag_start_y;
            
            select_all();
        }
    }
}
