import asyncio

from mpf.modes.game.code.game import Game


class HeadToHeadGame(Game):
    def __init__(self, *arg, **kwargs):
        super().__init__(*arg, **kwargs)
        self.log.debug("Head To Head Game init")
        self.lives_max = 6 #AD - changed to 2 for testing purposes

    async def _start_ball(self, is_extra_ball=False):
        """Start Head to Head ball."""
        self.debug_log("***************************************************")
        self.debug_log("****************** BALL STARTING ******************")
        self.debug_log("**                                               **")
        self.debug_log("**    Player: {}    Ball: {}   Score: {}".format(self.player.number,
                                                                         self.player.ball,
                                                                         self.player.score
                                                                        ).ljust(49) + '**')
        self.debug_log("**                                               **")
        self.debug_log("***************************************************")
        self.debug_log("***************************************************")

        await self.machine.events.post_async('ball_will_start',
                                                  is_extra_ball=is_extra_ball)
        '''event: ball_will_start
        desc: The ball is about to start. This event is posted just before
        :doc:`ball_starting`.'''

        await self.machine.events.post_queue_async(
            'ball_starting',
            balls_remaining=self.balls_per_game - self.player.ball,
            is_extra_ball=is_extra_ball)

        '''event: ball_starting
        desc: A ball is starting. This is a queue event, so the ball won't
        actually start until the queue is cleared.'''

        # register handlers to watch for ball drain and live ball removed
        self.add_mode_event_handler('ball_drain', self.ball_drained)

        self.balls_in_play = 2
        self.set_balls_for_side("front", 1)
        self.set_balls_for_side("back", 1)

        self.debug_log("ball_started for Ball %s", self.player.ball)

        await self.machine.events.post_async('ball_started',
                                                  ball=self.player.ball,
                                                  player=self.player.number)
        '''event: ball_started
        desc: A new ball has started.
        args:
        ball: The ball number.
        player: The player number.'''

        if self.num_players == 1:
            await self.machine.events.post_async('single_player_ball_started')
            '''event: single_player_ball_started
            desc: A new ball has started, and this is a single player game.'''
        else:
            await self.machine.events.post_async('multi_player_ball_started')
            '''event: multi_player_ball_started
            desc: A new ball has started, and this is a multiplayer game.'''
            await self.machine.events.post_async(
                'player_{}_ball_started'.format(self.player.number))
            '''event player_(number)_ball_started
            desc: A new ball has started, and this is a multiplayer game.
            The player number is the (number) in the event that's posted.'''

        self.machine.ball_devices['bd_trough_front'].eject(balls=1, target=self.machine.ball_devices['playfield'])
        self.machine.ball_devices['bd_trough_back'].eject(balls=1, target=self.machine.ball_devices['playfield'])

        self.player.lives_front = self.lives_max
        self.player.lives_back = self.lives_max

        self.machine.variables.set_machine_var("winner", None)

    def add_lives(self, side, lives):
        self.player["lives_{}".format(side)] += lives

    def ball_drained(self, balls=0, **kwargs):
        self.log.debug("Entering HeadtoHeadGame.ball_drained()")

        device = kwargs['device']

        if balls:
            if device == self.machine.ball_devices['bd_trough_back']:
                self.add_lives("back", -balls)
                self.log.debug("Back lost %s live. Now %s lives.", balls, self.player.lives_back)
            elif device == self.machine.ball_devices['bd_trough_front']:
                self.add_lives("front", -balls)
                self.log.debug("Front lost %s live. Now %s lives.", balls, self.player.lives_front)
            else:
                self.log.error("Unknown ball_device to drain %s", device.name)

            if self.player.lives_front <= 0 and self.player.lives_back <= 0: #changed or to and because I want the game to keep on going till both are 0
#                if not self.machine.variables.get_machine_var("winner"): #AD - I don't care who wins - removed
#                    # who wins?
#                    if self.player.lives_front <= 0: #AD - I don't care who wins - removed
#                        self.machine.variables.set_machine_var("winner", "back") #AD - I don't care who wins - removed
#                    else:
#                        self.machine.variables.set_machine_var("winner", "front") #AD - I don't care who wins - removed
                self.end_ball()
                
                return {'balls': balls}

#            if device == self.machine.ball_devices['bd_trough_back']:
#                # if back is empty. add a new ball
#                if self.get_balls_for_side("back") - balls < 1:
#                    self.log.debug("Adding ball to playfield")#AD was pf back
#
#                    self.machine.ball_devices['bd_trough_back'].eject(balls=1, target=self.machine.ball_devices['playfield'])#AD - was playfield_back
#                    balls -= 1
#
#                # remove balls from pf
#                self.add_balls_for_side("back", -balls)
#
#            elif device == self.machine.ball_devices['bd_trough_front']:
#                # if front is empty. add a new ball
#                if self.get_balls_for_side("front") - balls < 1:
#                    self.log.debug("Adding ball to playfield")#AD was pf front
#
#                    self.machine.ball_devices['bd_trough_front'].eject(balls=1, target=self.machine.ball_devices['playfield']) #AD - was playfield_front
#                    balls -= 1
#
#                # remove balls from pf
#                self.add_balls_for_side("front", -balls)

        if balls:
            self.log.debug("Processing %s newly-drained ball(s)", balls)
            self.balls_in_play -= balls

        return {'balls': balls}

    def get_balls_for_side(self, side):
        """Return ball for side."""
        return self.player["balls_{}".format(side)]

    def set_balls_for_side(self, side, value):
        """Set ball for side."""
        self.machine.events.post("balls_on_side_changed", side=side)
        self.player["balls_{}".format(side)] = value

    def add_balls_for_side(self, side, value):
        """Add balls for side."""
        self.set_balls_for_side(side, self.get_balls_for_side(side) + value)

    @property
    def balls_in_play(self):
        """Return balls in play."""
        return self._balls_in_play

    @balls_in_play.setter
    def balls_in_play(self, value):
        """Set balls in play.

        Same as in game but do not automatically end game when balls_in_play becomes 0.
        """
        prev_balls_in_play = self._balls_in_play

        if value > self.machine.ball_controller.num_balls_known:
            self._balls_in_play = self.machine.ball_controller.num_balls_known

        elif value < 0:
            self._balls_in_play = 0

        else:
            self._balls_in_play = value

        self.log.debug("Balls in Play change. New value: %s, (Previous: %s)",
                       self._balls_in_play, prev_balls_in_play)

        if self._balls_in_play > 0:
            self.machine.events.post('balls_in_play',
                                     balls=self._balls_in_play)
            '''event: balls_in_play
            desc: The number of balls in play has just changed, and there is at
            least 1 ball in play.

            Note that the number of balls in play is not necessarily the same
            as the number of balls loose on the playfield. For example, if the
            player shoots a lock and is watching a cut scene, there is still
            one ball in play even though there are no balls on the playfield.

            args:
            balls: The number of ball(s) in play.'''
