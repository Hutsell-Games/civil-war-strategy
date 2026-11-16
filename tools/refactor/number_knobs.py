#!/usr/bin/env python3
"""Replace numbers in the rules and the computer's code with tuning knobs (2026-11-16).

    python -I tools/refactor/number_knobs.py report   # checks every entry; changes nothing
    python -I tools/refactor/number_knobs.py apply
    python -I tools/refactor/number_knobs.py put-back <copy>   # the numbers again, in a copy of the game

Each entry is a file, a line, the text as it is and the text with the knob's variable. The text
must be on that line exactly once, or nothing is written. The knobs are those of
tools/tuning/knobs.txt; a fraction is a DOUBLE (name#). Four constants of cws.bi and one SINGLE
knob are renamed in every source file. The line numbers are those of the day this ran.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

LW = "battle_leader_weight# * army_leader_rating({0}) + battle_experience_weight# * army_experience({0})"
EDITS = {
    "rules/battle.bm": [
        (21, ".01 * army_size(attacker)", "attack_per_size# * army_size(attacker)"),
        (25, ".3 * army_leader_rating(attacker) + .3 * army_experience(attacker)", LW.format("attacker")),
        (28, "> 8 THEN", "> veteran_experience THEN"),
        (34, ".5 * attack_strength", "small_army_strength# * attack_strength"),
        (39, "attack_strength - 2", "attack_strength - attack_outnumbered_penalty"),
        (45, "attack_strength + 2", "attack_strength + attack_outnumbering_bonus"),
        (56, ".5 * attack_strength", "no_supply_strength# * attack_strength"),
        (63, "+ 2 * balance_help", "+ balance_strength * balance_help"),
        (68, ".013 * army_size(defender) + 1", "defense_per_size# * army_size(defender) + defense_base"),
        (70, ".02 * army_size(defender) + 2", "defense_per_size_realism# * army_size(defender) + defense_base_realism"),
        (71, "> 20 THEN", "> defense_most_realism THEN"),
        (72, "= 20", "= defense_most_realism"),
        (77, ".3 * army_leader_rating(defender) + .3 * army_experience(defender)", LW.format("defender")),
        (80, "> 8 THEN", "> veteran_experience THEN"),
        (86, ".5 * defend_strength", "small_army_strength# * defend_strength"),
        (95, "defend_strength + 2", "defend_strength + defend_outnumbering_bonus"),
        (97, ".5 * defend_strength", "defend_badly_outnumbered# * defend_strength"),
        (99, ".8 * defend_strength", "defend_outnumbered# * defend_strength"),
        (108, ".5 * defend_strength", "no_supply_strength# * defend_strength"),
        (115, "+ 2 * balance_help", "+ balance_strength * balance_help"),
        (181, "> 800", "> huge_army_size"),
        (182, ".8 * loss_rate!", "huge_army_loss# * loss_rate!"),
        (183, "> 300", "> large_army_size"),
        (184, ".9 * loss_rate!", "large_army_loss# * loss_rate!"),
        (193, ".03 * city_fort", "fort_defender_loss# * city_fort"),
        (195, "1.3 * loss_rate!", "attacker_wins_loss# * loss_rate!"),
        (202, ".02 * city_fort", "fort_attacker_loss# * city_fort"),
        (204, "1.5 * loss_rate!", "defender_wins_loss# * loss_rate!"),
        (211, ".8 * attacker_losses + .2 * defender_losses",
         "loss_own_share# * attacker_losses + loss_other_share# * defender_losses"),
        (215, ".8 * defender_losses + .2 * attacker_losses",
         "loss_own_share# * defender_losses + loss_other_share# * attacker_losses"),
        (219, "> 9 * defender_losses", "> attacker_loss_most_times * defender_losses"),
        (220, "= 9 * defender_losses", "= attacker_loss_most_times * defender_losses"),
        (222, "> 5 * attacker_losses", "> defender_loss_most_times * attacker_losses"),
        (223, "= 5 * attacker_losses", "= defender_loss_most_times * attacker_losses"),
    ],
    "rules/army.bm": [
        (153, "1 + 8 * RND", "1 + made_up_leader_spread * RND"),
        (195, "3 + 5 * RND", "new_army_supply + new_army_supply_spread * RND"),
        (197, "+ 2", "+ union_new_army_supply"),
        (201, "= 2", "= rebel_new_army_experience"),
        (205, "troops = 70", "troops = new_army_size"),
        (234, "offer_count = 4", "offer_count = recruit_cities_offered"),
        (285, "troops = 45", "troops = reinforce_size"),
        (303, "3 * city_value(city) + 33", "recruit_per_value * city_value(city) + recruit_base"),
        (305, "2 * city_value(city) + 20", "reinforce_per_value * city_value(city) + reinforce_base"),
        (314, "troops \\ 3", "troops \\ recruit_cut_off_divisor"),
        (322, "+ 5 * balance_help", "+ balance_recruits * balance_help"),
        (413, "army_experience(army) < 6", "army_experience(army) < drill_experience_below"),
        (430, ".3 * army_supply(army)", "detach_share# * army_supply(army)"),
        (435, ".3 * army_size(army)", "detach_share# * army_size(army)"),
    ],
    "rules/city.bm": [
        (60, "+ 100", "+ capital_capture_points"),
        (61, "- 100", "- capital_capture_points"),
        (134, "+ 50", "+ capital_move_points"),
    ],
    "rules/navy.bm": [
        (93, "fleet_size(side) < 2", "fleet_size(side) < invade_ships_least"),
        (125, "2 * cost_ship", "ironclad_cost_times * cost_ship"),
        (163, ".005 * fleet_size(side) + .02 * RND", "bombard_loss_per_ship# * fleet_size(side) + bombard_loss_spread# * RND"),
        (183, ".7 + .03 * (", "fort_damage_chance# + fort_damage_per_ship# * ("),
        (194, "+ 5", "+ fleet_lost_points"),
        (206, ".25 + .07 * fleet_size(side)", "blast_base# + blast_per_ship# * fleet_size(side)"),
        (233, "= 35", "= invasion_army_size"),
        (259, ".8 + .02 * fleet_size(raider)", "raid_chance# + raid_chance_per_ship# * fleet_size(raider)"),
        (261, ".05 * fleet_size(raider)", "raid_loss_per_ship# * fleet_size(raider)"),
        (265, "> .3 THEN", "> raid_loss_most_share# THEN"),
        (266, "= .3 * side_income", "= raid_loss_most_share# * side_income"),
        (282, "= 10", "= wooden_ship_hits"),
        (284, "= 20", "= ironclad_hits"),
        (297, "= .1", "= ironclad_aim_bonus#"),
        (299, "= -.1", "= -ironclad_aim_bonus#"),
        (303, "<= .5 + ironclad_bonus!", "<= ship_hit_chance# + ironclad_bonus!"),
        (312, "+ 10", "+ fleet_sunk_points"),
    ],
    "rules/railroad.bm": [
        (62, "= 11", "= rail_union_cities"),
        (64, "= 23", "= rail_rebel_cities"),
        (66, "+ 5 * (", "+ rail_per_city * ("),
        (67, "2 * train_capacity", "rail_most_times * train_capacity"),
        (71, "\\ 4", "\\ rail_least_divisor"),
        (72, "\\ 4", "\\ rail_least_divisor"),
    ],
    "rules/setup.bm": [
        (38, "- 100 + 200 * RND", "- vary_cash_shift + vary_cash_spread * RND"),
        (39, "+ 100 + 200 * RND", "+ vary_cash_shift + vary_cash_spread * RND"),
        (258, "+ 100 * (DIFFICULTY_EVEN", "+ start_cash_per_balance * (DIFFICULTY_EVEN"),
        (263, "+ 50 * RND", "+ start_cash_spread * RND"),
    ],
    "rules/turn.bm": [
        (57, "turn_month < 3", "turn_month <= winter_months"),
        (77, ">= .2 * army_size", ">= upkeep_per_size# * army_size"),
        (84, "- .2 * army_size", "- upkeep_per_size# * army_size"),
        (99, "RND > .8 AND army_size(army) > 50", "RND > starve_roll# AND army_size(army) > starve_size_above"),
        (100, ".9 * army_size", "starve_keep_share# * army_size"),
        (153, "11 * RND", "defender_halt_roll * RND"),
        (204, "+ 25", "+ army_destroyed_points"),
        (233, "RND > .8", "RND > forage_roll#"),
        (339, ".8 * side_victory_points(side) + .3 * (", "points_kept# * side_victory_points(side) + points_per_income# * ("),
        (340, "> 29", "> cities_bonus_above"),
        (341, "+ 50", "+ cities_bonus"),
        (342, "> 34", "> cities_big_bonus_above"),
        (343, "+ 100", "+ cities_big_bonus"),
    ],
    "rules/victory.bm": [
        (43, "+ 300", "+ wiped_out_points"),
        (128, "+ 100", "+ victory_points_bonus"),
        (138, ".7 * side_victory_points", "time_limit_points_share# * side_victory_points"),
    ],
    "ai/army.bm": [
        (142, "+ 30 * RND", "+ ai_move_spread * RND"),
        (145, "score - 25", "score - ai_leave_fort_penalty"),
        (147, "score - 50", "score - ai_leave_fort_realism_penalty"),
        (153, "score + 200", "score + ai_enemy_capital_bonus"),
        (157, "5 * city_value(to_city) + 10 * city_fort(to_city)",
         "ai_target_value * city_value(to_city) + ai_target_fort * city_fort(to_city)"),
        (160, "10 * city_value(to_city)", "ai_empty_enemy_value * city_value(to_city)"),
        (169, "score + 2", "score + ai_march_direction_bonus"),
        (172, "score + 2", "score + ai_march_direction_bonus"),
        (199, "weight = 200", "weight = ai_stay_weight_even"),
        (201, "weight = 80", "weight = ai_stay_weight_strong"),
        (203, "weight = 20", "weight = ai_stay_weight_stronger"),
        (205, "weight = 5", "weight = ai_stay_weight_strongest"),
        (235, "+ 20 * opt_ai_aggression", "+ ai_aggression_strength * opt_ai_aggression"),
        (283, "score - 15", "score - ai_realism_penalty"),
        (294, "score - 100", "score - ai_no_supply_penalty"),
        (300, "score - 300", "score - ai_odds_bad_penalty"),
        (302, "score - 20", "score - ai_odds_low_penalty"),
        (304, "score - 5", "score - ai_odds_even_penalty"),
        (306, "score + 10", "score + ai_odds_good_bonus"),
        (308, "+ 50 * RND", "+ ai_attack_spread * RND"),
        (330, "3 * city_value(far_city) + 4 * city_fort(far_city)",
         "ai_beyond_value * city_value(far_city) + ai_beyond_fort * city_fort(far_city)"),
        (333, "3 * city_value(far_city) + 4 * city_fort(far_city)",
         "ai_beyond_value * city_value(far_city) + ai_beyond_fort * city_fort(far_city)"),
    ],
    "ai/forces.bm": [
        (102, "2 + 3 * current_side + 3 * RND", "ai_armies_base + ai_armies_per_side * current_side + ai_armies_spread * RND"),
        (105, "fleet_size(side) < 5", "fleet_size(side) < ai_fleet_wanted"),
        (182, "army_size(army) < 155", "army_size(army) < ai_reinforce_below"),
    ],
}

# Renamed as whole words in every source file: four constants that become knobs, and the knob
# that was a SINGLE.
RENAMES = {b"MAX_ARMY_SIZE": b"max_army_size", b"SMALL_ARMY_SIZE": b"small_army_size",
           b"MIN_DETACH_SIZE": b"min_detach_size", b"RESUPPLY_LEVEL": b"resupply_level"}
SINGLE_KNOB = (b"union_bonus_realism_share!", b"union_bonus_realism_share#")


def put_back(root: Path) -> int:
    """In a copy of the game at root, puts the numbers back where the knobs are, to compare play."""
    for name, edits in EDITS.items():
        path = root / name
        data = path.read_bytes()
        eol = b"\r\n" if b"\r\n" in data else b"\n"
        lines = data.split(eol)
        for number, old, new in edits:
            if lines[number - 1].count(new.encode()) != 1:
                print(f"{name}:{number}: {new!r} is not there once; nothing written")
                return 1
            lines[number - 1] = lines[number - 1].replace(new.encode(), old.encode())
        path.write_bytes(eol.join(lines))
    print(f"numbers put back in {root}")
    return 0


def main() -> int:
    if sys.argv[1:2] == ["put-back"]:
        return put_back(Path(sys.argv[2]).resolve())
    apply = sys.argv[1:] == ["apply"]
    wrong, new_files = 0, {}
    for name, edits in EDITS.items():
        path = ROOT / name
        data = path.read_bytes()
        eol = b"\r\n" if b"\r\n" in data else b"\n"
        lines = data.split(eol)
        for number, old, new in edits:
            line = lines[number - 1]
            if line.count(old.encode()) != 1:
                wrong += 1
                print(f"{name}:{number}: {old!r} is there {line.count(old.encode())} times: {line.decode('latin-1').strip()}")
                continue
            lines[number - 1] = line.replace(old.encode(), new.encode())
        new_files[path] = eol.join(lines)
    if wrong:
        print(f"{wrong} entries do not match; nothing written")
        return 1
    pattern = re.compile(rb"(?<![A-Za-z0-9_])(" + b"|".join(RENAMES) + rb")(?![A-Za-z0-9_])")
    sources = [p for p in ROOT.rglob("*") if p.suffix.lower() in (".bm", ".bas", ".bi")
               and "out" not in p.relative_to(ROOT).parts]
    renamed = 0
    for path in sources:
        data = new_files.get(path, path.read_bytes())
        changed, count = pattern.subn(lambda m: RENAMES[m.group(1)], data)
        changed = changed.replace(*SINGLE_KNOB)
        if changed != data or path in new_files:
            new_files[path] = changed
            renamed += count
    print(f"{sum(len(e) for e in EDITS.values())} numbers in {len(EDITS)} files, {renamed} renames of constants")
    if apply:
        for path, data in new_files.items():
            path.write_bytes(data)
        print(f"wrote {len(new_files)} files")
    return 0


if __name__ == "__main__":
    sys.exit(main())
