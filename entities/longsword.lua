ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Base = "haloveh_base"
ENT.Type = "vehicle"

ENT.PrintName = "GA-TL1 Longsword"
ENT.Author = "Cody Evans"
--- BASE AUTHOR: Liam0102 ---
ENT.Category = "Halo Vehicles: UNSC"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false;
ENT.AdminSpawnable = false;

ENT.EntModel = "models/helios/longsword/longsword_open.mdl"
ENT.Vehicle = "longsword"
ENT.StartHealth = 2000;
ENT.Allegiance = "UNSC";

ENT.WingsModel = "models/helios/longsword/longsword_open.mdl"
ENT.ClosedModel = "models/helios/longsword/longsword.mdl"

list.Set("HaloVehicles", ENT.PrintName, ENT);

if SERVER then

ENT.FireSound = Sound("weapons/heavy_shoot.wav");
ENT.NextUse = {Wings = CurTime(),Use = CurTime(),Fire = CurTime(),};

AddCSLuaFile();
function ENT:SpawnFunction(pl, tr)
	local e = ents.Create("longsword");
	e:SetPos(tr.HitPos + Vector(0,0,0));
	e:SetAngles(Angle(0,pl:GetAimVector():Angle().Yaw,0));
	e:Spawn();
	e:Activate();
	return e;
end

function ENT:Initialize()

	self:SetNWInt("Health",self.StartHealth);
	
	self.WeaponLocations = {
		Left = self:GetPos()+self:GetForward()*390+self:GetUp()*60+self:GetRight()*-128,
		Right = self:GetPos()+self:GetForward()*390+self:GetUp()*60+self:GetRight()*128,
	}
	self.WeaponsTable = {};
	self.BoostSpeed = 2400;
	self.ForwardSpeed = 2400;
	self.UpSpeed = 1000;
	self.AccelSpeed = 10;
	self.CanStandby = false;
	self.CanBack = true;
	self.CanRoll = false;
	self.CanStrafe = true;
	self.Cooldown = 2;
	self.CanShoot = true;
	self.Bullet = CreateBulletStructure(300,"unsc");
	self.FireDelay = 0.2;
	self.NextBlast = 1;
	self.AlternateFire = true;
	self.DontOverheat = true;
	self.FireGroup = {"Left","Right",};
	
	self.PilotVisible = true;
	self.PilotPosition = {x=-26,y=645,z=148};
	self.PilotAnim = "drive_jeep";
	self.ExitModifier = {x = 0, y = 560, z = 135};
    self.CanEject = false;
	
	self.SeatPos = {
            
		{self:GetPos()+self:GetForward()*655+self:GetUp()*150+self:GetRight()*24,self:GetAngles()+Angle(0,0,0)},
	}
	self:SpawnSeats();
	self.HasLookaround = true;

	self.BaseClass.Initialize(self);
	
end

function ENT:SpawnSeats()
	self.Seats = {};
	for k,v in pairs(self.SeatPos) do
		local e = ents.Create("prop_vehicle_prisoner_pod");
		e:SetPos(v[1]);
		e:SetAngles(v[2]+Angle(0,-90,0));
		e:SetParent(self);		
		e:SetModel("models/nova/airboat_seat.mdl");
		e:SetRenderMode(RENDERMODE_TRANSALPHA);
		e:SetColor(Color(255,255,255,0));	
		e:Spawn();
		e:Activate();
		e:SetUseType(USE_OFF);
		e:GetPhysicsObject():EnableMotion(false);
		e:GetPhysicsObject():EnableCollisions(false);
		e.IsLongswordSeat = true;
		e.Longsword = self;
		self.Seats[k] = e;
	end

end

function ENT:Enter(p)
    self:SetModel(self.ClosedModel);
	self.BaseClass.Enter(self,p);
end

function ENT:Exit(kill)
    self:SetModel(self.WingsModel);
	self.BaseClass.Exit(self,kill);
end

hook.Add("PlayerEnteredVehicle","LongswordSeatEnter", function(p,v)
	if(IsValid(v) and IsValid(p)) then
		if(v.IsLongswordSeat) then
			p:SetNetworkedEntity("Longsword",v:GetParent());
            p:SetNetworkedEntity("LongswordSeat",v);
		end
	end
end);

hook.Add("PlayerLeaveVehicle", "LongswordSeatExit", function(p,v)
	if(IsValid(p) and IsValid(v)) then
		if(v.IsLongswordSeat) then
            if(v.LongswordFrontSeat) then
                local self = v:GetParent();
                p:SetPos(self:GetPos()+self:GetForward()*270+self:GetUp()*170);
            else
                p:SetPos(v:GetPos()+v:GetForward()*-100+v:GetUp()*-15+v:GetRight()*-20);
            end
			p:SetNetworkedEntity("Longsword",NULL);
            p:SetNetworkedEntity("LongswordSeat",NULL);
		end
	end
end);

function ENT:Passenger(p)
	if(self.NextUse.Use > CurTime()) then return end;
	for k,v in pairs(self.Seats) do
		if(v:GetPassenger(1) == NULL) then
			p:EnterVehicle(v);
			return;			
		end
	end
end


function ENT:Use(p)
	if(not self.Inflight) then
		if(!p:KeyDown(IN_WALK)) then
            local min = self:GetPos()+self:GetForward()*500+self:GetUp()*100+self:GetRight()*0;
            local max = self:GetPos()+self:GetForward()*800+self:GetUp()*180+self:GetRight()*-50
            for k,v in pairs(ents.FindInBox(min,max)) do
               if(v == p) then
                    self:Enter(p);
                    break;
                end
            end	
		else
			self:Passenger(p);
		end
	else
		if(p != self.Pilot) then
			self:Passenger(p);
		end
	end
end

function ENT:Think()
 
    if(self.Inflight) then
        if(IsValid(self.Pilot)) then
            if(IsValid(self.Pilot)) then 
                if(self.Pilot:KeyDown(IN_ATTACK2) and self.NextUse.FireBlast < CurTime()) then
                    self.BlastPositions = {
                        self:GetPos() + self:GetForward() * 725 + self:GetRight() * 120 + self:GetUp() * 70, //1
						self:GetPos() + self:GetForward() * 725 + self:GetRight() * -120 + self:GetUp() * 70, //1
						self:GetPos() + self:GetForward() * 725 + self:GetRight() * 120 + self:GetUp() * 70, //2
						self:GetPos() + self:GetForward() * 725 + self:GetRight() * -120 + self:GetUp() * 70, //2
						self:GetPos() + self:GetForward() * 725 + self:GetRight() * 120 + self:GetUp() * 70, //3
						self:GetPos() + self:GetForward() * 725 + self:GetRight() * -120 + self:GetUp() * 70, //3
                    }
                    self:FireBlast(self.BlastPositions[self.NextBlast], false, 800, 800, true, 8, Sound("weapons/hornet_missle.wav"));
					self.NextBlast = self.NextBlast + 1;
					if(self.NextBlast == 7) then
						self.NextUse.FireBlast = CurTime()+15;
						self:SetNWBool("OutOfMissiles",true);
						self:SetNWInt("FireBlast",self.NextUse.FireBlast)
						self.NextBlast = 1;
					end
					
					
                end
			end
		end
		
		if(self.NextUse.FireBlast < CurTime()) then
			self:SetNWBool("OutOfMissiles",false);
		end
        self:SetNWInt("Overheat",self.Overheat);
        self:SetNWBool("Overheated",self.Overheated);
    end
    self.BaseClass.Think(self);
end

function ENT:FireBlast(pos,gravity,vel,dmg,white,size,snd)
	if(self.NextUse.FireBlast < CurTime()) then
		local e = ents.Create("longsword_blast");
		
		e.Damage = dmg or 600;
		e.IsWhite = white or false;
		e.StartSize = size or 40;
		e.EndSize = e.StartSize*5 or 15;
		
		
		local sound = snd or Sound("weapons/hornet_missle.wav");
		
		e:SetPos(pos);
		e:Spawn();
		e:Activate();
		e:Prepare(self,sound,gravity,vel);
		e:SetColor(Color(255,160,0,1));
	end
	
end

end

if CLIENT then
	
	ENT.CanFPV = true;
	ENT.Sounds={
		Engine=Sound("vehicles/pelican_fly.wav"),
	}
	
	hook.Add("ScoreboardShow","LongswordScoreDisable", function()
		local p = LocalPlayer();	
		local Flying = p:GetNWBool("Longsword");
		if(Flying) then
			return false;
		end
	end)
	
	function ENT:Initialize()
		self.Emitter = ParticleEmitter(self:GetPos());
		self.BaseClass.Initialize(self);
	end
	
	local View = {}
	local lastpos, lastang;
	local function LongswordCalcView()
		
		local p = LocalPlayer();
		local self = p:GetNWEntity("Longsword",NULL)
        local flying = p:GetNWBool("FlyingLongsword");
		local pos,face;
        if(flying) then
            if(IsValid(self)) then
                local fpvPos = self:GetPos()+self:GetUp()*180+self:GetForward()*650+self:GetRight()*-24;
                if(LightSpeed == 2 and !self:GetFPV()) then
                    pos = lastpos;
                    face = lastang;

                    View.origin = pos;
                    View.angles = face;
                else
                    pos = self:GetPos()+self:GetUp()*650+LocalPlayer():GetAimVector():GetNormal()*-1300;			
                    face = ((self:GetPos() + Vector(0,0,100))- pos):Angle()
                    View =  HALOVehicleView(self,2080,480,fpvPos,true);
                end

                lastpos = pos;
                lastang = face;

                return View;
            end
        else
            local v = p:GetNWEntity("LongswordSeat",NULL);
            if(IsValid(v)) then
                if(v:GetThirdPersonMode()) then
                    return HALOVehicleView(self,1880,480,fpvPos);
                end
            end
        end
	end
	hook.Add("CalcView", "LongswordView", LongswordCalcView)
	
	function ENT:Effects()
	

		local p = LocalPlayer();
		local roll = math.Rand(-45,45);
		local normal = (self.Entity:GetRight() * -1):GetNormalized();
		local FWD = self:GetRight();
		local id = self:EntIndex();
		for k,v in pairs(self.EnginePos) do
			
			local blue = self.FXEmitter:Add("sprites/orangecore1",v+FWD*25)
			blue:SetVelocity(normal)
			blue:SetDieTime(0.12)
			blue:SetStartAlpha(150)
			blue:SetEndAlpha(20)
			blue:SetStartSize(40)
			blue:SetEndSize(30)
			blue:SetRoll(roll)
			blue:SetColor(255,255,255)

		end
	end
	
	function ENT:Think()
	
		
		
		local p = LocalPlayer();
		local Flying = self:GetNWBool("Flying".. self.Vehicle);
		local TakeOff = self:GetNWBool("TakeOff");
		local Land = self:GetNWBool("Land");
		if(Flying) then
			if(!TakeOff and !Land) then
				self.EnginePos = {
					self:GetPos()+self:GetRight()*-325+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*-365+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*-407.5+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*-450+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*-490+self:GetUp()*110+self:GetForward()*-485,
					
					self:GetPos()+self:GetRight()*280+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*440+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*320+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*400+self:GetUp()*110+self:GetForward()*-485,
					self:GetPos()+self:GetRight()*360+self:GetUp()*110+self:GetForward()*-485,
				}
				self:Effects();
			end
		end
		self.BaseClass.Think(self)
	end
	
	function LongswordReticle()
		
		local p = LocalPlayer();
		local Flying = p:GetNWBool("FlyingLongsword");
		local self = p:GetNWEntity("Longsword");
		if(Flying and IsValid(self)) then
			HALO_HUD_DrawHull(2000);
			HALO_WeaponReticles(self);
			HALO_BlastIcon(self,15);			
			HALO_HUD_Compass(self,x,y); // Draw the compass/radar
			HALO_HUD_DrawSpeedometer();
		end
	end
	hook.Add("HUDPaint", "LongswordReticle", LongswordReticle)

end