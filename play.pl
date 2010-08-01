#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Dominion::Game;
use List::Util qw(sum);

my $game = Dominion::Game->new();
my $p1 = Dominion::Player->new(name => 'Martyn');
my $p2 = Dominion::Player->new(name => 'Fred');
my $p3 = Dominion::Player->new(name => 'Harold');
$game->player_add($p1);
$game->player_add($p2);
$game->player_add($p3);
$game->start;

my $count = 0;
while ( $game->active_player ) {
    my $state = $game->state;

    use Data::Dump qw(dump);
    dump($state);

    given ( $state->{state} ) {
        when ( 'gameover' ) {
            print "Game over\n";
            print "---------\n";
            foreach my $player ( $game->players ) {
                my $vp = $player->deck->total_victory_points;
                printf "%s => %d points (%d cards)\n", $player->name, $vp, $player->deck->count;
            }
            exit 0;
        }
        when ( 'action' ) {
            my $card_name = ($game->active_player->hand->cards_of_type('action'))[0]->name;
            $game->active_player->play($card_name);
        }
        when ( 'buy' ) {
            my $coin = $state->{coin};
            while ( $coin >= 0 ) {
                my @card_names = map { $_->name } grep { $_->cost_coin == $coin } $game->supply->cards;
                unless ( @card_names ) {
                    $coin--;
                    next;
                }
                my $card_name = @card_names[int rand() * @card_names];
                $game->active_player->buy($card_name);
                last;
            }
        }
        default { die "Can't deal with state: $state->{state}" }
    }
}

