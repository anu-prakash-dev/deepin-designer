using Gtk;
using Layouts;

namespace Layouts {
    public class RectangleLayout : Layouts.Layout {
        public RectangleLayout() {
            
        }
        
        public void init(int init_x, int init_y, int init_width, int init_height) {
            x = init_x;
            y = init_y;
            width = init_width;
            height = init_height;
            
            is_active = true;
        }
        
        public override void draw_layout(Cairo.Context cr) {
            Utils.set_context_color(cr, background_color);
            Draw.draw_rectangle(cr, x + 1, y + 1, width - 2, height - 2);
            
            Utils.set_context_color(cr, frame_color);
            Draw.draw_rectangle(cr, x, y, width, height);
            
            if (is_active) {
                // Top left drag dot.
                int drag_dot_x = x - drag_dot_size / 2;
                int drag_dot_y = y - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Top middle drag dot.
                drag_dot_x = x + width / 2 - drag_dot_size / 2;
                drag_dot_y = y - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Top right drag dot.
                drag_dot_x = x + width - drag_dot_size / 2;
                drag_dot_y = y - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Bottom left drag dot.
                drag_dot_x = x - drag_dot_size / 2;
                drag_dot_y = y + height - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Bottom middle drag dot.
                drag_dot_x = x + width / 2 - drag_dot_size / 2;
                drag_dot_y = y + height - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Bottom right drag dot.
                drag_dot_x = x + width - drag_dot_size / 2;
                drag_dot_y = y + height - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Left drag dot.
                drag_dot_x = x - drag_dot_size / 2;
                drag_dot_y = y + height / 2 - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);

                // Right drag dot.
                drag_dot_x = x + width - drag_dot_size / 2;
                drag_dot_y = y + height / 2 - drag_dot_size / 2;
                
                Utils.set_context_color(cr, drag_dot_background_color);
                Draw.draw_rectangle(cr, drag_dot_x + 1, drag_dot_y + 1, drag_dot_size - 2, drag_dot_size - 2);
                
                Utils.set_context_color(cr, drag_dot_frame_color);
                Draw.draw_rectangle(cr, drag_dot_x, drag_dot_y, drag_dot_size, drag_dot_size);
            }
        }
    }
}