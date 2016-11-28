all: main
main: ./lib/animation.vala \
      ./lib/constant.vala \
      ./lib/draw.vala \
      ./lib/config.vala \
      ./lib/keymap.vala \
      ./lib/menu.vala \
      ./lib/utils.vala \
      ./lib/xutils.vala \
      ./widget/layout.vala \
      ./widget/image_button.vala \
      ./widget/toolbar.vala \
      ./widget/page_panel.vala \
      ./widget/layout_panel.vala \
      ./widget/layout_manager.vala \
      ./widget/window_event_area.vala \
      ./widget/dialog.vala \
      ./widget/workspace.vala \
      ./widget/page_manager.vala \
      ./widget/page.vala \
      ./widget/pencil_layout.vala \
      ./widget/oval_layout.vala \
      ./widget/image_layout.vala \
      ./widget/text_layout.vala \
      ./widget/pentagon_layout.vala \
      ./widget/five_pointed_layout.vala \
      ./widget/rounded_rectangle_layout.vala \
      ./widget/rectangle_layout.vala \
      ./widget/triangle_layout.vala \
      ./widget/line_layout.vala \
      ./project_path.c \
      ./widget/window.vala \
      main.vala
	valac -o main \
	-X -w \
	-X -lm \
	-X -DGETTEXT_PACKAGE="deepin-designer" \
    --pkg=gtk+-3.0 \
    --pkg=gee-0.8 \
    --pkg=json-glib-1.0 \
    --pkg=gio-2.0 \
    --pkg=posix \
    --pkg=gdk-x11-3.0 \
    --pkg=xcb \
    --pkg=libsecret-1 \
    --vapidir=./vapi \
    ./lib/animation.vala \
    ./lib/constant.vala \
    ./lib/draw.vala \
    ./lib/config.vala \
    ./lib/keymap.vala \
    ./lib/menu.vala \
    ./lib/utils.vala \
    ./lib/xutils.vala \
    ./widget/layout.vala \
	./widget/image_button.vala \
	./widget/toolbar.vala \
	./widget/page_panel.vala \
	./widget/layout_panel.vala \
	./widget/layout_manager.vala \
	./widget/window_event_area.vala \
	./widget/dialog.vala \
	./widget/workspace.vala \
	./widget/page_manager.vala \
	./widget/page.vala \
    ./widget/pencil_layout.vala \
    ./widget/oval_layout.vala \
    ./widget/image_layout.vala \
    ./widget/text_layout.vala \
    ./widget/pentagon_layout.vala \
    ./widget/five_pointed_layout.vala \
    ./widget/rounded_rectangle_layout.vala \
    ./widget/rectangle_layout.vala \
    ./widget/triangle_layout.vala \
    ./widget/line_layout.vala \
    ./project_path.c \
    ./widget/window.vala \
    main.vala

clean:
	rm -f main
	rm -f main.vala.c
	rm -f ./lib/*.vala.c
	rm -f ./widget/*.vala.c

