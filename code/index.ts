export async function add(event: { n1: number; n2: number }) {
  return { n1: event.n1 + event.n2 };
}

export async function square(event: { n1: number }) {
  return event.n1 * event.n1;
}
