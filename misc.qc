void() light_torch_small_walltorch;
void() bulb_break;
void() info_null = 
{
	remove(self);
};

void() info_notnull = 
{
};

float START_OFF = 1;

void() light_use = 
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

void() light = 
{
	if (self.health == SVC_SELLSCREEN)
	{
		self.weapon2 = "REAL";
		light_torch_small_walltorch();
	}
	else
	{
		if (!(self.targetname))
		{
			remove(self);
			return;
		}
		else
		{
			if (self.style >= DOOR_TOGGLE)
			{
				self.use = light_use;
				if (self.spawnflags & START_OFF)
				{
					lightstyle(self.style, "a");
				}
				else
				{
					lightstyle(self.style, "m");
				}
			}
		}
	}
};

void() light_fluoro = 
{
	if (self.style >= DOOR_TOGGLE)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
		{
			lightstyle(self.style, "a");
		}
		else
		{
			lightstyle(self.style, "m");
		}
	}
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", 0.3, ATTN_STATIC);
};

void() light_fluorospark = 
{
	if (!(self.style))
	{
		self.style = SVC_SETVIEWANGLES;
	}
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

void() light_globe = 
{
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

void() FireAmbient = 
{
	precache_sound("ambience/fire1.wav");
	ambientsound(self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

void() light_torch_small_walltorch = 
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	self.skin = MSG_BROADCAST;
	self.frame = MSG_BROADCAST;
	self.classname = "breakable_bulb";
	precache_model("progs/bulb.mdl");
	precache_model("progs/glass1.mdl");
	precache_model("progs/glass2.mdl");
	setmodel(self, "progs/bulb.mdl");
	setsize(self, '-8 -8 -8', '8 8 8');
	precache_sound("misc/glass1.wav");
	self.health = WEAPON_SHOTGUN;
	self.th_die = bulb_break;
	self.takedamage = DAMAGE_YES;
};

void() bulb_break = 
{
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.classname = "breakable_bulb";
	sound(self, CHAN_VOICE, "misc/glass1.wav", WEAPON_SHOTGUN, ATTN_NORM);
	self.skin = WEAPON_SHOTGUN;
	if (random() * SVC_SETVIEWANGLES >= TE_WIZSPIKE)
	{
		self.frame = WEAPON_SHOTGUN;
	}
	else
	{
		self.frame = WEAPON_ROCKET;
	}
	if (self.health <= -80)
	{
		self.frame = AS_MELEE;
	}
	self.effects = self.effects | EF_MUZZLEFLASH;
	ThrowGib("progs/glass1.mdl", -60);
	ThrowGib("progs/glass2.mdl", -40);
	ThrowGib("progs/glass1.mdl", -20);
	ThrowGib("progs/glass2.mdl", -70);
	if (self.weapon2 == "REAL")
	{
		lightstyle(self.style, "a");
	}
};

void() light_flame_large_yellow = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	self.frame = WEAPON_SHOTGUN;
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_yellow = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};

void() light_flame_small_white = 
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	FireAmbient();
	makestatic(self);
};
void() fire_fly;
void() fire_touch;
void() misc_fireball = 
{
	precache_model("progs/lavaball.mdl");
	self.classname = "fireball";
	self.nextthink = time + random() * SVC_SETVIEWPORT;
	self.think = fire_fly;
	if (!(self.speed))
	{
		self.speed == 1000;
	}
};

void() fire_fly = 
{
	local entity fireball;
	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = random() * 100 - 50;
	fireball.velocity_y = random() * 100 - 50;
	fireball.velocity_z = self.speed + random() * 200;
	fireball.classname = "fireball";
	setmodel(fireball, "progs/lavaball.mdl");
	setsize(fireball, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(fireball, self.origin);
	fireball.nextthink = time + SVC_SETVIEWPORT;
	fireball.think = SUB_Remove;
	fireball.touch = fire_touch;
	self.nextthink = time + random() * SVC_SETVIEWPORT + AS_MELEE;
	self.think = fire_fly;
};

void() fire_touch = 
{
	T_Damage(other, self, self, 20);
	remove(self);
};

void() Laser_Touch = 
{
	local vector org;
	if (other == self.owner)
	{
		return;
	}
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	sound(self, CHAN_WEAPON, "enforcer/enfstop.wav", WEAPON_SHOTGUN, ATTN_STATIC);
	org = self.origin - WEAPON_BIG * normalize(self.velocity);
	if (other.health)
	{
		SpawnBlood(org, self.velocity * 0.2, 15, other);
		T_Damage(other, self, self.owner, 15);
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord(MSG_BROADCAST, org_x);
		WriteCoord(MSG_BROADCAST, org_y);
		WriteCoord(MSG_BROADCAST, org_z);
	}
	remove(self);
};

void(vector org, vector vec) LaunchLaser = 
{
	if (self.classname == "monster_enforcer")
	{
		sound(self, CHAN_WEAPON, "enforcer/enfire.wav", WEAPON_SHOTGUN, ATTN_NORM);
	}
	vec = normalize(vec);
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;
	setmodel(newmis, "progs/laser.mdl");
	setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(newmis, org);
	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);
	newmis.nextthink = time + SVC_SETVIEWPORT;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

void() spikeshooter_use = 
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound(self, CHAN_VOICE, "enforcer/enfire.wav", WEAPON_SHOTGUN, ATTN_NORM);
		LaunchLaser(self.origin, self.movedir);
	}
	else
	{
		sound(self, CHAN_VOICE, "weapons/spike2.wav", WEAPON_SHOTGUN, ATTN_NORM);
		launch_spike(self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
		{
			newmis.touch = superspike_touch;
		}
	}
};

void() shooter_think = 
{
	spikeshooter_use();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};

void() trap_spikeshooter = 
{
	SetMovedir();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model("progs/laser.mdl");
		precache_sound("enforcer/enfire.wav");
		precache_sound("enforcer/enfstop.wav");
	}
	else
	{
		precache_sound("weapons/spike2.wav");
	}
};

void() trap_shooter = 
{
	trap_spikeshooter();
	if (self.wait == MSG_BROADCAST)
	{
		self.wait = WEAPON_SHOTGUN;
	}
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};

void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

void() air_bubbles = 
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model("progs/s_bubble.spr");
	self.nextthink = time + WEAPON_SHOTGUN;
	self.think = make_bubbles;
};

void() make_bubbles = 
{
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = MSG_BROADCAST;
	bubble.cnt = MSG_BROADCAST;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split = 
{
	local entity bubble;
	bubble = spawn();
	setmodel(bubble, "progs/s_bubble.spr");
	setorigin(bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.1;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = WEAPON_SHOTGUN;
	bubble.cnt = SVC_SETVIEWANGLES;
	setsize(bubble, '-8 -8 -8', '8 8 8');
	self.frame = WEAPON_SHOTGUN;
	self.cnt = SVC_SETVIEWANGLES;
	if (self.waterlevel != AS_MELEE)
	{
		remove(self);
	}
};

void() bubble_remove = 
{
	if (other.classname == self.classname)
	{
		return;
	}
	remove(self);
};

void() bubble_bob = 
{
	local float rnd1;
	local float rnd2;
	local float rnd3;
	local vector vtmp1;
	local vector modi;
	if (pointcontents(self.origin) != CONTENT_WATER)
	{
		remove(self);
	}
	self.cnt = self.cnt + WEAPON_SHOTGUN;
	if (self.cnt == SECRET_NO_SHOOT)
	{
		remove(self);
	}
	rnd1 = self.velocity_x + (-10 + random() * 20);
	rnd2 = self.velocity_y + (-10 + random() * 20);
	rnd3 = self.velocity_z + SVC_SETVIEWANGLES + random() * SVC_SETVIEWANGLES;
	if (rnd1 > SVC_SETVIEWANGLES)
	{
		rnd1 = SVC_SETVIEWPORT;
	}
	if (rnd1 < -10)
	{
		rnd1 = CONTENT_LAVA;
	}
	if (rnd2 > SVC_SETVIEWANGLES)
	{
		rnd2 = SVC_SETVIEWPORT;
	}
	if (rnd2 < -10)
	{
		rnd2 = CONTENT_LAVA;
	}
	if (rnd3 < SVC_SETVIEWANGLES)
	{
		rnd3 = 15;
	}
	if (rnd3 > SVC_INTERMISSION)
	{
		rnd3 = 25;
	}
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

void() viewthing = 
{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model("progs/player.mdl");
	setmodel(self, "progs/player.mdl");
};

void() func_wall_use = 
{
	self.frame = WEAPON_SHOTGUN - self.frame;
};

void() func_wall = 
{
	self.angles = VEC_ORIGIN;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() func_illusionary = 
{
	self.angles = VEC_ORIGIN;
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel(self, self.model);
	makestatic();
};

void() func_episodegate = 
{
	if (!(serverflags & self.spawnflags))
	{
		return;
	}
	self.angles = VEC_ORIGIN;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() func_bossgate = 
{
	if ((serverflags & 15) == 15)
	{
		return;
	}
	self.angles = VEC_ORIGIN;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.use = func_wall_use;
	setmodel(self, self.model);
};

void() ambient_suck_wind = 
{
	precache_sound("ambience/suck1.wav");
	ambientsound(self.origin, "ambience/suck1.wav", WEAPON_SHOTGUN, ATTN_STATIC);
};

void() ambient_drone = 
{
	precache_sound("ambience/pulse8.wav");
	ambientsound(self.origin, "ambience/pulse8.wav", WEAPON_SHOTGUN, ATTN_NORM);
};

void() ambient_disco = 
{
	precache_sound("ambience/disco.wav");
	ambientsound(self.origin, "ambience/disco.wav", WEAPON_SHOTGUN, ATTN_NORM);
};

void() ambient_disco2 = 
{
	precache_sound("ambience/disco2.wav");
	ambientsound(self.origin, "ambience/disco2.wav", WEAPON_SHOTGUN, ATTN_NORM);
};

void() ambient_flouro_buzz = 
{
	precache_sound("ambience/buzz1.wav");
	ambientsound(self.origin, "ambience/buzz1.wav", WEAPON_SHOTGUN, ATTN_STATIC);
};

void() ambient_drip = 
{
	precache_sound("ambience/drip1.wav");
	ambientsound(self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};

void() ambient_comp_hum = 
{
	precache_sound("ambience/comp1.wav");
	ambientsound(self.origin, "ambience/comp1.wav", WEAPON_SHOTGUN, ATTN_STATIC);
};

void() ambient_thunder = 
{
	precache_sound("ambience/thunder1.wav");
	ambientsound(self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};

void() ambient_light_buzz = 
{
	precache_sound("ambience/fl_hum1.wav");
	ambientsound(self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

void() ambient_swamp1 = 
{
	precache_sound("ambience/swamp1.wav");
	ambientsound(self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};

void() ambient_swamp2 = 
{
	precache_sound("ambience/swamp2.wav");
	ambientsound(self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

