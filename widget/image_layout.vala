using Layouts;

namespace Layouts {
    public class ImageLayout : Layout {
        public string image_path;
        public Cairo.ImageSurface image_surface;
            
        public ImageLayout() {
        }
            
        public override void draw_layout(Cairo.Context cr) {
            if (can_draw) {
                Draw.draw_surface(cr, image_surface, x, y);
            }
        }
            
        public override void update_track(Gtk.Widget widget, int drag_start_x, int drag_start_y, int? drag_x, int? drag_y) {
            Gtk.FileChooserAction action = Gtk.FileChooserAction.OPEN;
            var chooser = new Gtk.FileChooserDialog("Select image", widget.get_toplevel() as Gtk.Window, action);
            chooser.add_button("Cancel", Gtk.ResponseType.CANCEL);
            chooser.set_select_multiple(true);
            chooser.add_button("Select", Gtk.ResponseType.ACCEPT);
                
            if (chooser.run() == Gtk.ResponseType.ACCEPT) {
                can_draw = true;
                
                x = drag_start_x;
                y = drag_start_y;
                    
                var file_list = chooser.get_files();
                foreach (File file in file_list) {
                    image_path = file.get_path();
                    image_surface = new Cairo.ImageSurface.from_png(image_path);
                        
                    width = image_surface.get_width();
                    height = image_surface.get_height();
                    break;
                }
            }
                
            chooser.destroy();
        }
    }
}

