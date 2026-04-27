export {};

declare global {
  interface Window {
    javaBridge?: {
      // resetDps?: () => void;
      moveWindow?: (x: number, y: number) => void;
      getDpsData?: () => void;

      getVersion?: () => string;

      getBattleList?: () => void;
      getBattleDetail?: (id: number) => Promise<any>;

      getBattleDetailFromList?: (idx: number, id: number) => Promise<any>;
      getLiveBuffOperatingRate?: (id: number) => Promise<any>;
      getLiveBossBuffOperatingRate?: () => Promise<any>;
      getBuffOperatingRate?: (idx: number, id: number) => Promise<any>;
      getBossBuffOperatingRate?: (idx: number) => Promise<any>;

      openBrowser?: (url: string) => void;
      exitApp?: () => void;
    };
  }
}
