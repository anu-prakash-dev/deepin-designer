using Gtk;
using Gee;
using Layouts;

namespace Widgets {
    public class LayoutManager {
        public ArrayList<Layouts.Layout> layout_list;
        
        public LayoutManager() {
            layout_list = new ArrayList<Layouts.Layout>();
        }
        
        public Layouts.Layout? add_layout(string layout_type, int x, int y, int w, int h) {
            if (layout_type == "Rectangle") {
                var layout = new Layouts.RectangleLayout();
                layout.init(x, y, w, h);
                
                layout_list.add(layout);
                
                return layout;
            }
            
            return null;
        }
    }
}