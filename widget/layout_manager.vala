using Gtk;
using Gee;
using Layouts;

namespace Widgets {
    public class LayoutManager {
        public ArrayList<Layouts.Layout> layout_list;
        
        public LayoutManager() {
            layout_list = new ArrayList<Layouts.Layout>();
        }
        
        public Layouts.Layout add_layout(string layout_type) {
            Layouts.Layout layout = new Layouts.Layout();
            layout.type = layout_type;
            
            layout_list.add(layout);
            
            return layout;
        }
    }
}