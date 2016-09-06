namespace Layouts {
    public class Layout {
        public int x;
        public int y;
        public int width;
        public int height;
        public Gdk.RGBA frame_color;
        public Gdk.RGBA background_color;
        
        public Layout() {
            frame_color = Utils.hex_to_rgba("#303030", 0.1);
            background_color = Utils.hex_to_rgba("#ff0000", 0.1);
        }
        
        public virtual void draw_layout(Cairo.Context cr) {
            
        }
    }
}