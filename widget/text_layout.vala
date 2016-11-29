using Layouts;

namespace Layouts {
    public class TextLayout : Layout {
        public string text = "Type \nsomething";
        public int text_size = 20;
        public int line_height = 42;
        public Gdk.RGBA text_color;
        public Gdk.RGBA cursor_color;
        public int cursor_width = 2;
        public int cursor_index = 0;
		public int cursor_trailing = 0;
		public int column_offset = 0;
		public Pango.Layout layout;		
            
        public TextLayout() {
            text_color = Utils.hex_to_rgba("#000000", 1.0);
            cursor_color = Utils.hex_to_rgba("#ff1e00", 1.0);
        }
            
        public override void draw_layout(Cairo.Context cr) {
            cr.save();
            
            // Draw text.
            Utils.set_context_color(cr, text_color);
                
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
            
            cr.move_to(x, render_y);
            Pango.cairo_update_layout(cr, layout);
            Pango.cairo_show_layout(cr, layout);

            // Draw cursor.
            if (!is_create_finish) {
                int[] index_coordinate = index_to_line_x(cursor_index, cursor_trailing);
                int line = index_coordinate[0];
                int x_pos = index_coordinate[1];
                Utils.set_context_color(cr, cursor_color);
                Draw.draw_rectangle(cr, x + x_pos / Pango.SCALE, y + line * line_height, cursor_width, line_height);
            }
            
            cr.restore();
        }
        
        public bool handle_key_press(string keyname) {
            if (keyname == "Ctrl + f" || keyname == "Right") {
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
            } else if (keyname == "Ctrl + a" || keyname == "Home") {
				move_beginning_of_line();
                return true;
			} else if (keyname == "Ctrl + e" || keyname == "End") {
				move_end_of_line();
                return true;
			} else if (keyname == "Alt + f") {
				forward_word();
                return true;
			} else if (keyname == "Alt + b") {
				backward_word();
                return true;
			} else if (keyname == "Esc") {
                is_create_finish = true;
                return true;
            }
            
            return false;
        }
        
		public bool forward_char() {
			int new_index, new_trailing;
			layout.move_cursor_visually(true, cursor_index, cursor_trailing, 1, out new_index, out new_trailing);
			
			if (new_index != int.MAX) {
				cursor_index = new_index;
				cursor_trailing = new_trailing;
			}
			
			return new_index == int.MAX;
        }
        
        public bool backward_char() {
			int new_index, new_trailing;
			layout.move_cursor_visually(true, cursor_index, cursor_trailing, -1, out new_index, out new_trailing);
			
			if (new_index >= 0) {
				cursor_index = new_index;
				cursor_trailing = new_trailing;
			}
			
			return new_trailing == -1;
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
			int line = get_cursor_line();

			int new_index, new_trailing;
			layout.xy_to_index(column_offset, (line + 1) * line_height * Pango.SCALE, out new_index, out new_trailing);
			cursor_index = new_index;
			cursor_trailing = new_trailing;
        }
        
        public void prev_line() {
			int line = get_cursor_line();

			int new_index, new_trailing;
			layout.xy_to_index(column_offset, (line - 1) * line_height * Pango.SCALE, out new_index, out new_trailing);
			cursor_index = new_index;
			cursor_trailing = new_trailing;
        }
		
		public void move_beginning_of_line() {
			int[] line_bound = find_line_bound();
			cursor_index = line_bound[0];
			cursor_trailing = 0;
		}
		
		public void move_end_of_line() {
			int[] line_bound = find_line_bound();
			cursor_index = line_bound[1];
			cursor_trailing = 1;
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

			found_next_char = text.get_next_char(ref cursor_index, out c);
			while (found_next_char && !reach_end) {
				if (is_word_bound_chars(c, is_skip)) {
                    if (c != '\n') {
                        backward_char();
                    }
                    
					reach_end = true;
				} else {
					found_next_char = text.get_next_char(ref cursor_index, out c);
					reach_end = !found_next_char;
				}
			}
		}

		public void forward_skip_indentation_chars() {
			bool reach_end = false;
			unichar c = 0;
			bool found_next_char = true;

			found_next_char = text.get_next_char(ref cursor_index, out c);
			while (found_next_char && !reach_end) {
				if (is_indentation_chars(c, true)) {
					backward_char();
					reach_end = true;
				} else {
					found_next_char = text.get_next_char(ref cursor_index, out c);
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

			found_prev_char = text.get_prev_char(ref cursor_index, out c);
			while (found_prev_char && !reach_end) {
				if (is_word_bound_chars(c, is_skip)) {
					forward_char();
					reach_end = true;
				} else {
					found_prev_char = text.get_prev_char(ref cursor_index, out c);
					reach_end = !found_prev_char;
				}
			}
		}
		
		public int[] find_line_bound() {
			int[] line_bound = new int[2];
			
			line_bound[0] = text.substring(0, cursor_index).last_index_of_char('\n') + 1;
			line_bound[1] = text.index_of_char('\n', cursor_index);
			
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
			return index_to_line_x(cursor_index, cursor_trailing)[0];
		}
		
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            can_draw = true;
                
            x = drag_start_x;
            y = drag_start_y;
        }
    }
}
