using Gtk;
using Gee;

namespace Widgets {
    public class LayoutManager {
        public ArrayList<Layout> layout_list;
        
        public LayoutManager() {
            layout_list = new ArrayList<Layout>();
        }
        
        public void add_layout(Layout layout) {
            layout_list.add(layout);
        }
    }
}