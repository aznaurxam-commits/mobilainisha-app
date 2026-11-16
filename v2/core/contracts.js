/* Interface contracts for future server implementation; no fake backend. */
export const API=Object.freeze({
  session:'/api/v1/session',
  verifyPhone:'/api/v1/auth/verify-phone',
  stores:'/api/v1/stores',
  products:'/api/v1/products',
  inventory:'/api/v1/inventory',
  orders:'/api/v1/orders',
  repairs:'/api/v1/repairs',
  staff:'/api/v1/staff',
  audit:'/api/v1/audit-events'
});
export const REPAIR_STATES=Object.freeze(['requested','intake_pending','accepted','diagnostics','approval_pending','approved','repairing','waiting_parts','quality_check','ready','payment_pending','handover_pending','issued','rejected','returned_unrepaired']);
export function isValidOrder(order){return !!order&&typeof order.id==='string'&&Array.isArray(order.items)&&typeof order.storeId==='number'}
export function isValidRepair(repair){return !!repair&&typeof repair.id==='string'&&typeof repair.storeId==='number'&&REPAIR_STATES.includes(repair.status)}
