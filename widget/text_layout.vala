using Layouts;

namespace Layouts {
    public class TextLayout : Layout {
        public string text = "Type something";
        public int text_size = 20;
        public Gdk.RGBA text_color;
            
        public TextLayout() {
            text_color = Utils.hex_to_rgba("#000000", 1.0);
        }
            
        public override void draw_layout(Cairo.Context cr) {
            cr.save();
                
            Utils.set_context_color(cr, text_color);
                
            var font_description = new Pango.FontDescription();
            font_description.set_size((int)(text_size * Pango.SCALE));
            
            var layout = Pango.cairo_create_layout(cr);
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
            
            cr.restore();
        }
            
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            can_draw = true;
                
            x = drag_start_x;
            y = drag_start_y;
        }
    }
}
