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
            Layouts.Layout? layout = null;
            if (layout_type == "Rectangle") {
                layout = Layouts.create_rectangle_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Triangle") {
                layout = Layouts.create_triangle_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Five_Pointed_Star") {
                layout = Layouts.create_five_pointed_star_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Pentagon") {
                layout = Layouts.create_pentagon_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Oval") {
                layout = Layouts.create_oval_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Rounded_Rectangle") {
                layout = Layouts.create_rounded_rectangle_layout(layout_type, x, y, w, h);
            } else if (layout_type == "Line") {
                layout = Layouts.create_line_layout(layout_type, x, y, w, h);
            }
            
            if (layout != null) {
                layout_list.add(layout);
            }
            
            return layout;
        }
    }
}