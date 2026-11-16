/* MOBILAINISHA 2.0: policy helpers only. Server MUST enforce all authorization. */
export const ROLES=Object.freeze(['customer','seller','master','manager','courier','accountant','owner']);
export const STORES=Object.freeze(['Хоста','Кудепста','Блиново','Чайсовхоз']);
export function resolveHome(session){
  if(!session?.verifiedPhone) return 'login';
  const roles=Array.isArray(session.roles)?session.roles:[];
  if(roles.includes('owner')) return 'owner';
  if(roles.some(role=>ROLES.includes(role)&&role!=='customer')&&session.employeeActive===true) return 'work';
  return 'customer';
}
export function canSwitchToWork(session){return resolveHome(session)==='work'||resolveHome(session)==='owner'}
export function canViewStore(session,storeId){
  if(!session?.verifiedPhone||!STORES[storeId])return false;
  if(session.roles?.includes('owner'))return true;
  return session.employeeActive===true&&Array.isArray(session.storeIds)&&session.storeIds.includes(storeId);
}
