from kittens.tui.handler import result_handler


def main(args):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss):
    in_zen_mode = getattr(boss, 'in_zen_mode', False)
    boss.change_font_size("all", "-" if in_zen_mode else '+', 5.0)
    boss.toggle_fullscreen()
    boss.in_zen_mode = not in_zen_mode
