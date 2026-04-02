export interface RawPlayerValue {
  user?: {
    id?: number;
    nickname?: string;
    job?: string;
    isExecutor?: boolean;
  };
  amount?: number | string;
  dps?: number | string;
  damageContribution?: number | string;
}
export interface RawCombatData {
  map?: Record<string, RawPlayerValue | number>;
  targetName?: string;
  battleTime?: number;
}

export interface Player {
  id: string;
  name: string;
  job: string;
  dps: number;
  amount: number;
  damageContribution: number;
  isUser: boolean;
  server: number;
}
export interface CombatRaw {
  combatants: Record<string, any>;
}
export interface Skill {
  code: string;
  name: string;
  time: number;
  crit: number;
  parry: number;
  back: number;
  perfect: number;
  double: number;
  dmg: number;
  critPct: number | "-";
  parryPct: number | "-";
  perfectPct: number | "-";
  doublePct: number | "-";
  backPct: number | "-";
}

export interface Details {
  totalDmg: number;
  contributionPct: number;
  totalCritPct: number;
  totalParryPct: number;
  totalBackPct: number;
  totalPerfectPct: number;
  totalDoublePct: number;
  combatTime: string;
  skills: Skill[];
}

export interface Hotkey {
  modifiers: number;
  vkCode: number;
}
export type PanelType = "details" | "settings" | "history" | null;
